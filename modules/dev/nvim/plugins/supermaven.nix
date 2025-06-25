{config, ...}: {
  programs.nixvim.plugins.supermaven = {
    enable = true;
    settings = {
      keymaps = {
        accept_suggestion = null; #"<C-Tab>";
        clear_suggestion = "<C-]>";
        accept_word = "<C-j>";
      };
      color = {
        suggestion_color = "#ffffff";
        cterm = 244;
      };
      log_level = "info";
      disable_inline_completion = true;
      disable_keymaps = false;
      condition = config.lib.nixvim.mkRaw ''
        function() return false end
      '';
    };
  };
}
