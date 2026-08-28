{
  boot = {
    growPartition = true;
    supportedFilesystems.btrfs = true;
  };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Lexar_SSD_NM620_2TB_PKA615R000980P110N";
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
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "/opt" = {
                  mountpoint = "/opt";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "/var/lib" = {
                  mountpoint = "/var/lib";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                  ];
                };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "36G";
                };
              };
            };
          };
        };
      };
    };
  };
}
