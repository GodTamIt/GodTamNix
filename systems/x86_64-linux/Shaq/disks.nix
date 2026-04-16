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
        device = "/dev/disk/by-id/nvme-SHPP41-2000GM_BNE6N52281150745B";
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
              size = "128G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
                resumeDevice = true; # resume from hiberation from this device
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
}
