_: {
  sops = {
    defaultSopsFile = ../../../secrets/Shaq/default.yaml;
    validateSopsFiles = false;

    secrets = {
      cloudflare_api_token = {};
      "hermes-env" = {
        sopsFile = ../../../secrets/Shaq/hermes.yaml;
        format = "yaml";
      };
      "google-chat-sa" = {
        sopsFile = ../../../secrets/Shaq/google-chat-sa.json;
        path = "/var/lib/hermes/google-chat-sa.json";
        owner = "hermes";
        group = "hermes";
        mode = "0600";
      };
    };
  };
}
