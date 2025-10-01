{
  programs.nixvim.plugins = {
    auto-session = {
      enable = true;
      settings = {
        enabled = true;
        auto_restore = true;
        auto_save = true;
        suppressed_dirs = [
          "~/"
          "~/Downloads"
          "~/Documents"
          "~/Desktop"
        ];
      };
    };
  };
}
