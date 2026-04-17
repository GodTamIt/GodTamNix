_: {
  sops = {
    defaultSopsFile = ../../../secrets/Shaq/default.yaml;
    validateSopsFiles = false;

    secrets.cloudflare_api_token = {};
  };
}
