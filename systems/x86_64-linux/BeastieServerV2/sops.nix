_: {
  sops = {
    defaultSopsFile = ../../../secrets/BeastieServerV2/default.yaml;
    validateSopsFiles = false;

    secrets.cloudflare_api_token = {};
    secrets.cloudflare_acme_credentials = {};
  };
}
