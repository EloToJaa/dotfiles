{
  disko.devices.disk.main = {
    type = "disk";
    # DESTRUCTIVE: verify/change this on the target before installation.
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "1M";
          type = "EF02";
        };
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
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f"];
            subvolumes = {
              "@root" = {
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd" "noatime"];
              };
              "@state" = {
                mountpoint = "/var/lib";
                mountOptions = ["compress=zstd" "noatime"];
              };
            };
          };
        };
      };
    };
  };
}
