_:
let
  defaultBtrfsOpts = [
    "defaults"
    "ssd"
    "noatime"
    "nodiratime"
  ];
in
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZQL23T8HCLS-00A07_S64HNJ0T515306";
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
                mountOptions = [ "umask=0077" ];
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
              size = "64G";
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
