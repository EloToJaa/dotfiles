{
  disko.devices.disk.main = {
    type = "disk";
    # DESTRUCTIVE: verify/change this on the target before installation.
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S649NX0T144624B";
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
            # Leave key files unset for interactive password entry.
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
