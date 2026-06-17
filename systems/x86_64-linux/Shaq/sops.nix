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
        format = "binary";
        path = "/var/lib/hermes/google-chat-sa.json";
        owner = "hermes";
        group = "hermes";
        mode = "0600";
      };
      # Cookie-Editor JSON dump from instagram.com (sessionid, csrftoken,
      # ds_user_id, ...). Encrypted as binary so the full document is mounted
      # verbatim — see secrets/Shaq/README.md for the populate workflow.
      "instagram-cookies" = {
        sopsFile = ../../../secrets/Shaq/instagram-cookies.json;
        format = "binary";
        path = "/var/lib/hermes/instagram-cookies.json";
        owner = "hermes";
        group = "hermes";
        mode = "0600";
      };
    };
  };
}
