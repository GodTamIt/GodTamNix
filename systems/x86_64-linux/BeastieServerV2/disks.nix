_: let
  defaultBtrfsOpts = [
    "defaults"
    "ssd"
    "noatime"
    "nodiratime"
  ];
in {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNW010T8_BTNH93320UYL1P0B";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            efi = {
              priority = 1;
              name = "efi";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              name = "root";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--csum xxhash"
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultBtrfsOpts;
                  };
                };
              };
            };

            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
                extraArgs = [
                  "-Lswap"
                ];
              };
            };
          };
        };
      };
    };
  };

  fileSystems = {
    "/mnt/array" = {
      device = "UUID=5cdf6573-3c6e-4c30-87c3-f944781b06e0";
      fsType = "btrfs";
      mountPoint = "/mnt/array";
      options = [
        "subvol=/"
        "noatime"
        "noautodefrag"
        "nodiratime"
        "nofail"
        "space_cache=v2"
        "degraded"
      ];
    };

    "/mnt/array-media" = {
      device = "UUID=5cdf6573-3c6e-4c30-87c3-f944781b06e0";
      fsType = "btrfs";
      mountPoint = "/mnt/array-media";
      options = [
        "subvol=@media"
        "noatime"
        "noautodefrag"
        "nodiratime"
        "nofail"
        "space_cache=v2"
        "degraded"
      ];
    };

    "/mnt/backup" = {
      device = "UUID=19371eec-ca14-4e16-a842-8e0920c53d35";
      fsType = "btrfs";
      options = [
        "noatime"
        "noautodefrag"
        "nodiratime"
        "nofail"
        "space_cache=v2"
      ];
    };
  };

  godtamnix.services.btrfs.scrub = {
    enable = true;
    mounts = {
      root = {
        mountPoint = "/";
        interval = "*-*-15 04:00:00"; # monthly on the 15th
      };

      array = {
        mountPoint = "/mnt/array";
        interval = "*-01,04,07,10 09:30:00"; # every 3 months, started in the morning.
        preHook = "runuser -l godtamit -c 'podman pause transmission || true'";
        postHook = "runuser -l godtamit -c 'podman unpause transmission || true'";
      };

      backup = {
        mountPoint = "/mnt/backup";
        interval = "*-02,06,11 03:00:00";
      };
    };
  };

  services = {
    btrbk.instances."media" = {
      onCalendar = "*-*-* 09:15:00";
      settings = {
        timestamp_format = "long";

        # --- LOCAL snapshot retention (/mnt/array/@media/.snapshots) ---
        snapshot_preserve_min = "2d"; # keep everything for at least 2 days
        snapshot_preserve = "14d 4w"; # then 14 dailies + 4 weeklies

        # --- BACKUP target retention (/mnt/backup/@media), longer/different ---
        target_preserve_min = "no"; # no forced minimum; policy governs fully
        target_preserve = "7d 6w 4m"; # 7 dailies, 6 weeklies, 4 monthlies

        volume."/mnt/array" = {
          subvolume = "@media";
          snapshot_dir = "@media/.snapshots"; # -> /mnt/array/@media/.snapshots
          target = "/mnt/backup/@array/@media"; # plain local path, must be on btrfs
        };
      };
    };

    # Explicitly disable btrfs autoScrub since we use our own scrubbing utilities.
    btrfs.autoScrub = {
      enable = false;
    };
  };

  # btrbk creates neither the snapshot dir nor the target dir.
  systemd.tmpfiles.rules = [
    "d /mnt/array/@media/.snapshots       0755 root root"
    "d /mnt/backup/@array/@media          0755 root root"
  ];
}
