{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        keymap.preset = "super-tab";
        signature.enabled = true;
        # windows.autocomplete.select = "auto_insert";
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        completion = {
          accept = {
            auto_brackets = {
              enabled = true;
              semantic_token_resolution.enabled = false;
            };
          };
          documentation.auto_show = true;
        };
        sources = {
          # providers = {
          #   buffer = {
          #     score_offset = -7;
          #   };
          #   lsp = {
          #     fallbacks = [];
          #   };
          # };
          completion.enabled_providers = {
            __unkeyed-1 = "supermaven";
          };
          providers = {
            supermaven = {
              name = "supermaven";
              module = "blink.compat.source";
              score_offset = 3;
            };
          };
        };
      };
    };
    blink-compat = {
      enable = true;
      settings = {
        impersonate_nvim_cmp = true;
      };
    };
  };
}
