{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types mapAttrs filterAttrs mapAttrs';
  inherit (lib.btrfs.scrub) makeScrubService;

  cfg = config.godtamnix.services.btrfs.scrub;

  mountSubmodule = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable scrub for this mount.";
      };
      mountPoint = mkOption {
        type = types.str;
        default = "";
        example = "/data";
        description = ''
          Absolute path of the btrfs filesystem to scrub. This is the
          real path btrfs(8) operates on. Required.

          The systemd unit name is derived from the attrset key, not
          this path, so unrelated mounts with the same basename
          (e.g. `/data` and `/srv/data`) cannot collide.
        '';
      };
      interval = mkOption {
        type = types.str;
        default = "monthly";
        example = "Mon..Sun 04:00:00";
        description = ''
          systemd `OnCalendar` value for the timer. See
          systemd.time(7) for syntax.
        '';
      };
      nice = mkOption {
        type = types.int;
        default = 19;
        description = "Process nice level for the scrub.";
      };
      ioClass = mkOption {
        type = types.ints.between 0 3;
        default = 3;
        description = ''
          systemd `IOSchedulingClass` (0=none, 1=RT, 2=BE, 3=idle).
          The btrfs-progs default is idle (3).
        '';
      };
      preHook = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "echo 'starting scrub'";
        description = ''
          Shell snippet executed as `ExecStartPre`. Omitted entirely
          when `null`.
        '';
      };
      postHook = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "echo 'scrub finished'";
        description = ''
          Shell snippet executed as `ExecStartPost`. Omitted entirely
          when `null`.
        '';
      };
      extraArgs = mkOption {
        type = types.str;
        default = "";
        example = "-c 2 -n 4";
        description = "Extra args appended to `btrfs scrub start -B`.";
      };
    };
  };

  # attrset key is the only source of unit naming. Never derive
  # unit names from the mount path basename.
  unitName = name: "btrfs-scrub-${name}";

  # Filter to enabled mounts, build the service+timer pair once per
  # mount, then re-key the result sets by the unit name so systemd
  # sees the right unit names regardless of what the user picked
  # as attrset keys.
  active = filterAttrs (_: m: m.enable) cfg.mounts;

  pairs = mapAttrs (name: m:
    makeScrubService {
      inherit pkgs;
      inherit (m) mountPoint interval nice ioClass preHook postHook extraArgs;
      inherit name;
    })
  active;

  services =
    mapAttrs' (name: pair: {
      name = unitName name;
      value = pair.service;
    })
    pairs;

  timers =
    mapAttrs' (name: pair: {
      name = unitName name;
      value = pair.timer;
    })
    pairs;
in {
  options.godtamnix.services.btrfs.scrub = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Master switch for the per-mount btrfs scrub module. Coexists
        with the upstream `services.btrfs.autoScrub`; disable that
        one explicitly if you don't want both running.
      '';
    };

    mounts = mkOption {
      type = types.attrsOf mountSubmodule;
      default = {};
      example = lib.literalExpression ''
        {
          root = {
            mountPoint = "/";
            interval = "monthly";
          };
          data = {
            mountPoint = "/data";
            interval = "weekly";
            preHook = "echo 'starting data scrub'";
            postHook = "echo 'data scrub done'";
          };
        }
      '';
      description = ''
        Per-mount scrub definitions. The attrset key is the logical
        name used for the systemd unit (prefixed with `btrfs-scrub-`)
        and is the only source of unit naming. The mount path basename
        is intentionally never used, so unrelated mounts with the same
        basename cannot collide.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.all (m: m.mountPoint != "") (builtins.attrValues cfg.mounts);
        message = "godtamnix.services.btrfs.scrub: every mount must set `mountPoint`.";
      }
      {
        assertion = builtins.all (n: n != "") (builtins.attrNames cfg.mounts);
        message = "godtamnix.services.btrfs.scrub.mounts keys must be non-empty.";
      }
    ];

    systemd.services = services;
    systemd.timers = timers;
  };
}
