# Hermes Agent: Google Chat support.
#
# Upstream packaging gap (verified against hermes-agent main, 2026-06): the
# bundled `google_chat` platform plugin lazy-imports `google.cloud.pubsub_v1`,
# but `google-cloud-pubsub` is in NO hermes extra and absent from upstream
# `uv.lock`. So `check_google_chat_requirements()` fails and the gateway logs
# "No messaging platforms enabled" before it ever reads the GOOGLE_CHAT_* env
# vars. `extraPythonPackages` can't help — pubsub's deps (google-api-core,
# google-auth, protobuf) are already sealed in the venv, tripping the build's
# collision guard (the `google-api-python-client collides…` error).
#
# Fix: patch the input's source to add `google-cloud-pubsub` to the `google`
# extra (the always-on `all` group pulls it in) plus a matching regenerated
# `uv.lock`, then rebuild the package via the input's own builder. uv resolved
# this incrementally — only google-cloud-pubsub + the gRPC stack were added; no
# existing pin (protobuf 6.33.5, google-api-core 2.30.3, …) changed.
#
# To refresh after bumping the hermes-agent input: copy the input's pyproject +
# uv.lock, re-apply the one-line `google` extra edit, `uv lock`, and replace
# ./hermes/uv.lock.
{
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  ha = inputs.hermes-agent;

  patchedSrc = pkgs.runCommandLocal "hermes-agent-pubsub-src" {} ''
      cp -r --no-preserve=mode,ownership ${ha} $out
      cp ${./hermes/uv.lock} $out/uv.lock
      substituteInPlace $out/pyproject.toml \
        --replace-fail '  "google-auth-httplib2==0.3.1",' \
          '  "google-auth-httplib2==0.3.1",
    "google-cloud-pubsub>=2.34",'
  '';

  hermes-agent-pubsub = pkgs.callPackage "${patchedSrc}/nix/hermes-agent.nix" {
    inherit (ha.inputs) uv2nix pyproject-nix pyproject-build-systems;
    npm-lockfile-fix = ha.inputs.npm-lockfile-fix.packages.${system}.default;
    rev = null;
  };
in {
  services.hermes-agent.package = hermes-agent-pubsub;
}
