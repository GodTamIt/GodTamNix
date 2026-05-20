{config, ...}: {
  sops = {
    defaultSopsFile = ../../../secrets/BeastieMacBookV2/default.yaml;
    validateSopsFiles = false;

    age = {
      # macOS has no system SSH host key by default, so we don't derive an
      # age key from one. The user is expected to put their age private key
      # at the path below — see the bootstrap notes for how to generate it.
      keyFile = "${config.users.users.godtamit.home}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    # Secrets to decrypt at activation. Empty for now — add entries like:
    #   secrets.my_secret = {};
    # once you've encrypted `secrets/BeastieMacBookV2/default.yaml` with the
    # host's age public key (see .sops.yaml).
    secrets = {};
  };
}
