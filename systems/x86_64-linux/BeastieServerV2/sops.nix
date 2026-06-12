_: {
  sops = {
    defaultSopsFile = ../../../secrets/BeastieServerV2/default.yaml;
    validateSopsFiles = false;

    secrets = {
      cloudflare_api_token = {};
      cloudflare_acme_credentials = {};
      "hermes-env" = {
        sopsFile = ../../../secrets/BeastieServerV2/hermes.yaml;
        format = "yaml";
      };
    };
  };
}
