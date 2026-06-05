{inputs}: let
  inherit (inputs.nixpkgs) lib;
in {
  /**
  Build paired systemd service + timer attrsets for a single btrfs
  scrub. Each call is independent so different filesystems can scrub
  at different intervals, with different hooks, and at different
  priority/IO levels.

  Unit and script names are derived from the explicit `name`
  argument, never from the mount path. The mount path is only used
  in the `ExecStart` btrfs invocation (where btrfs(8) needs the real
  path) and in the description string.

  # Inputs

  `pkgs`
  : nixpkgs instance providing `btrfs-progs` and `writeShellScript`.

  `name`
  : Required logical identifier for this unit pair (e.g. "root",
    "data"). Used to build the unit suffix `btrfs-scrub-${name}`.
    Must be unique per host. Caller is responsible for uniqueness.

  `mountPoint`
  : Required absolute path of the btrfs filesystem to scrub.

  `interval`
  : systemd `OnCalendar` value. Default: `"monthly"`.

  `nice`
  : Process nice level. Default: `19`.

  `ioClass`
  : systemd `IOSchedulingClass` value (0=none, 1=RT, 2=BE, 3=idle).
    Default: `3` (idle).

  `preHook`
  : Optional shell snippet executed before the scrub. Omitted
    entirely when `null`. Default: `null`.

  `postHook`
  : Optional shell snippet executed after the scrub. Omitted
    entirely when `null`. Default: `null`.

  `extraArgs`
  : Extra args appended to `btrfs scrub start -B`. Default: `""`.

  `randomizedDelay`
  : `RandomizedDelaySec` value to stagger scrubs sharing a calendar
    expression. Default: `"1h"`. Set to `null` to omit.

  # Returns

  Attrset `{ service, timer }` ready for merge into
  `systemd.services.<name>` and `systemd.timers.<name>`.

  # Example

  ```
  let
    r = lib.btrfs.scrub.makeScrubService {
      inherit pkgs;
      name = "root";
      mountPoint = "/";
    };
  in {
    systemd.services.btrfs-scrub-root = r.service;
    systemd.timers.btrfs-scrub-root = r.timer;
  }
  ```
  */
  makeScrubService = {
    pkgs,
    name,
    mountPoint,
    interval ? "monthly",
    nice ? 19,
    ioClass ? 3,
    preHook ? null,
    postHook ? null,
    extraArgs ? "",
    randomizedDelay ? "1h",
  }: let
    btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
    scrubCmd =
      "${btrfs} scrub start -B"
      + lib.optionalString (extraArgs != "") " ${extraArgs}"
      + " ${mountPoint}";
  in {
    service = {
      description = "Btrfs scrub on ${mountPoint}";
      documentation = ["man:btrfs-scrub(8)"];
      # The timer is what activates this service. No wantedBy on the
      # service itself, otherwise it would start on every boot and
      # race the timer schedule.
      serviceConfig =
        {
          Type = "oneshot";
          ExecStart = scrubCmd;
          Nice = nice;
          IOSchedulingClass = ioClass;
          # Fail fast if the filesystem isn't actually mounted.
          RequiresMountsFor = [mountPoint];
        }
        // lib.optionalAttrs (preHook != null) {
          ExecStartPre = pkgs.writeShellScript "btrfs-scrub-${name}-pre" preHook;
        }
        // lib.optionalAttrs (postHook != null) {
          ExecStartPost = pkgs.writeShellScript "btrfs-scrub-${name}-post" postHook;
        };
    };
    timer = {
      description = "Periodic Btrfs scrub timer for ${mountPoint}";
      wantedBy = ["timers.target"];
      timerConfig =
        {
          OnCalendar = interval;
          # Run on next boot if a scheduled slot was missed while off.
          Persistent = true;
        }
        // lib.optionalAttrs (randomizedDelay != null) {
          RandomizedDelaySec = randomizedDelay;
        };
    };
  };
}
