{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge;

  cfg = config.godtamnix.services.web;
  vhostsCfg = cfg.vhosts;

  # Per-vhost server-level directives from DDoS protection. Concatenated
  # onto each vhost's `extraConfig`. Empty when protection is disabled
  # so we don't reference undefined zones.
  ddosServerDirectives = lib.optionalString cfg.ddosProtection ''
    limit_req zone=godtamnix_req burst=20 nodelay;
    limit_conn godtamnix_conn 10;
  '';
in {
  options.godtamnix.services.web = {
    nginx.enable = lib.mkEnableOption "nginx web server";

    ddosProtection = lib.mkEnableOption ''
      Per-IP request rate and connection limits. Cheap, nginx-native
      brute-force protection. Note: limits apply per client IP, so
      multiple users behind the same NAT will share a single bucket.
    '';

    vhosts = {
      jellyfin = {
        enable = lib.mkEnableOption "Jellyfin reverse-proxy vhost";

        domain = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            Public hostname for Jellyfin. Use `lib.godtamnix.decode` with
            the base64-encoded value so the actual hostname doesn't show
            up in `git grep`:
              domain = lib.godtamnix.decode "Y2hyaXNmbGl4LmdvZHRhbWl0LmNvbQ==";
            Required when `enable = true`.
          '';
        };

        upstream = lib.mkOption {
          type = lib.types.str;
          default = "http://127.0.0.1:8096";
          description = "Jellyfin backend URL (no trailing slash).";
        };
      };

      nextcloud = {
        enable = lib.mkEnableOption "Nextcloud reverse-proxy vhost";

        domain = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            Public hostname for Nextcloud. Use `lib.godtamnix.decode`
            with the base64-encoded value. Required when `enable = true`.
          '';
        };

        upstream = lib.mkOption {
          type = lib.types.str;
          default = "http://127.0.0.1:8087";
          description = "Nextcloud backend URL (no trailing slash).";
        };
      };

      immich = {
        enable = lib.mkEnableOption "Immich reverse-proxy vhost";

        domain = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            Public hostname for Immich. Use `lib.godtamnix.decode` with
            the base64-encoded value. Required when `enable = true`.
          '';
        };

        upstream = lib.mkOption {
          type = lib.types.str;
          default = "http://127.0.0.1:2283";
          description = "Immich backend URL (no trailing slash).";
        };
      };
    };
  };

  config = mkIf cfg.nginx.enable (mkMerge [
    # --- Global nginx + firewall --------------------------------------
    {
      networking.firewall.allowedTCPPorts = [80 443];

      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;

        appendHttpConfig = lib.optionalString cfg.ddosProtection ''
          # limit_req/limit_conn zones — referenced by per-server
          # `limit_req zone=...` / `limit_conn zone=...` directives.
          limit_req_zone   $binary_remote_addr zone=godtamnix_req:10m  rate=10r/s;
          limit_conn_zone  $binary_remote_addr zone=godtamnix_conn:10m;
        '';
      };
    }

    # --- Jellyfin vhost -----------------------------------------------
    (mkIf vhostsCfg.jellyfin.enable {
      services.nginx.virtualHosts.${vhostsCfg.jellyfin.domain} = {
        http2 = true;
        enableACME = true;
        forceSSL = true;

        extraConfig =
          ddosServerDirectives
          + ''

            client_max_body_size 1G;
            add_header X-XSS-Protection          "1; mode=block" always;
            add_header X-Content-Type-Options   "nosniff" always;
            add_header Strict-Transport-Security "max-age=31536000" always;
            add_header Content-Security-Policy "default-src https: data: blob: http://image.tmdb.org; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com/cv/js/sender/v1/cast_sender.js https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'";

            location = / {
              return 302 https://$host/web/;
            }
          '';

        locations."/" = {
          proxyPass = vhostsCfg.jellyfin.upstream;
          proxyWebsockets = false;
          extraConfig = ''
            proxy_buffering off;
            proxy_set_header Host                 $host;
            proxy_set_header X-Real-IP            $remote_addr;
            proxy_set_header X-Forwarded-For      $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto    $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host     $http_host;
          '';
        };

        locations."/socket" = {
          proxyPass = vhostsCfg.jellyfin.upstream;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host                 $host;
            proxy_set_header X-Real-IP            $remote_addr;
            proxy_set_header X-Forwarded-For      $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto    $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host     $http_host;
          '';
        };
      };
    })

    # --- Nextcloud vhost ----------------------------------------------
    (mkIf vhostsCfg.nextcloud.enable {
      services.nginx.virtualHosts.${vhostsCfg.nextcloud.domain} = {
        http2 = true;
        enableACME = true;
        forceSSL = true;

        extraConfig =
          ddosServerDirectives
          + ''

            client_max_body_size 0;
            add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
          '';

        locations = {
          "/" = {
            proxyPass = vhostsCfg.nextcloud.upstream;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_redirect off;
              proxy_set_header Host              $host;
              proxy_set_header X-Real-IP         $remote_addr;
              proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_read_timeout    1800;
              proxy_connect_timeout 1800;
            '';
          };

          "/.well-known/carddav" = {
            extraConfig = ''
              return 301 $scheme://$host/remote.php/dav;
            '';
          };

          "/.well-known/caldav" = {
            extraConfig = ''
              return 301 $scheme://$host/remote.php/dav;
            '';
          };
        };
      };
    })

    # --- Immich vhost -------------------------------------------------
    (mkIf vhostsCfg.immich.enable {
      services.nginx.virtualHosts.${vhostsCfg.immich.domain} = {
        http2 = true;
        enableACME = true;
        forceSSL = true;

        extraConfig =
          ddosServerDirectives
          + ''

            client_max_body_size 50000M;
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
            add_header X-Frame-Options            "DENY" always;
            add_header X-Content-Type-Options     "nosniff" always;
            add_header X-XSS-Protection           "1; mode=block" always;
            add_header Referrer-Policy            "origin" always;
          '';

        locations."/" = {
          proxyPass = vhostsCfg.immich.upstream;
          proxyWebsockets = true;
          extraConfig = ''
            proxy_redirect off;
            proxy_set_header Host              $http_host;
            proxy_set_header X-Real-IP         $remote_addr;
            proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    })
  ]);
}
