{
  boot.growPartition = true;
  boot.supportedFilesystems.btrfs = true;

  disko.devices.disk = {
    main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-KINGSTON_SKC3000D2048G_50026B7686C51E32";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              # disable settings.keyFile if you want to use interactive password entry
              #passwordFile = "/tmp/secret.key"; # Interactive
              settings.allowDiscards = true;
              # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "20M";
                  };
                };
              };
            };
          };
        };
      };
    };
    data = {
      type = "disk";
      device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_2TB_S5RPNF0W406592A";
      content = {
        type = "gpt";
        partitions.luks_data = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted_data";
            # passwordFile = "/tmp/data.key";
            settings.allowDiscards = true;
            # keyFile = "/tmp/data.key";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/data" = {
                  mountpoint = "/mnt/data";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          };
        };
      };
    };
    windows = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S649NL0T757428Z";
      content = {
        type = "gpt";
        partitions.windows = {
          size = "100%";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
          };
        };
      };
    };
  };
}
