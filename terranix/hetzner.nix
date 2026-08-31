{
  variable = {
    storage_box_id = {
      type = "number";
      description = "Hetzner API ID of the existing Storage Box.";
      sensitive = true;
    };
    storage_box_location = {
      type = "string";
      description = "Location of the existing Storage Box, for example fsn1.";
    };
    storage_box_name = {
      type = "string";
      description = "Name assigned to the existing Storage Box.";
    };
    storage_box_password = {
      type = "string";
      description = "Primary account password of the existing Storage Box.";
      sensitive = true;
    };
    storage_box_type = {
      type = "string";
      description = "Type of the existing Storage Box, for example bx21.";
    };
  };

  resource.hcloud_storage_box.borgbackup = {
    name = "\${var.storage_box_name}";
    storage_box_type = "\${var.storage_box_type}";
    location = "\${var.storage_box_location}";
    password = "\${var.storage_box_password}";
    delete_protection = true;
    access_settings = {
      reachable_externally = true;
      samba_enabled = false;
      ssh_enabled = true;
      webdav_enabled = false;
      zfs_enabled = false;
    };
    lifecycle.prevent_destroy = true;
  };

  import = [
    {
      to = "hcloud_storage_box.borgbackup";
      id = "\${var.storage_box_id}";
    }
  ];

  output.storage_box_server = {
    description = "Storage Box hostname.";
    value = "\${hcloud_storage_box.borgbackup.server}";
  };

  output.storage_box_username = {
    description = "Storage Box primary username.";
    value = "\${hcloud_storage_box.borgbackup.username}";
  };
}
