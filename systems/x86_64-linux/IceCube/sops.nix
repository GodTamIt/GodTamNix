_: {
  sops = {
    defaultSopsFile = ../../../secrets/IceCube/default.yaml;
    validateSopsFiles = false;

    secrets.cloudflare_api_token = {};
  };
}
