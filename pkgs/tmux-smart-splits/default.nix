{
  lib,
  fetchFromGitHub,
  tmuxPlugins,
}: let
  # Pinned to the last release that still ships smart-splits.tmux. v3.0.0 moved
  # every multiplexer backend out of smart-splits.nvim into its own repository
  # (smart-splits-nvim/backend-tmux) and deleted this file, so a version bump
  # here still builds but leaves tmux with no plugin to load. Excluded from the
  # nixbot package-update effects in ci/nixbot.nix for that reason.
  version = "2.1.1-final";
in
  tmuxPlugins.mkTmuxPlugin {
    pluginName = "smart-splits";
    rtpFilePath = "smart-splits.tmux";
    inherit version;

    src = fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "v${version}";
      hash = "sha256-HyTn+sT70BpPSEVWpPrsB5PRcOD23aAn3JdUDp031Fw=";
    };

    meta = {
      description = "Tmux side of smart-splits.nvim: seamless navigation and resizing across tmux panes and Neovim splits";
      homepage = "https://github.com/mrjones2014/smart-splits.nvim";
      license = lib.licenses.mit;
      maintainers = [];
      platforms = lib.platforms.all;
    };
  }
