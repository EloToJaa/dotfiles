{lib, ...}: {
  options.modules.home.nvim.plugins = {
    enable = lib.mkEnableOption "Enable plugins";
  };
  imports = [
    ./auto-session.nix
    ./bufferline.nix
    ./cmp.nix
    ./comment.nix
    ./format.nix
    ./git.nix
    ./indent-blankline.nix
    ./lint.nix
    ./lsp.nix
    ./lualine.nix
    ./lz-n.nix
    ./nix.nix
    ./noice.nix
    ./smart-splits.nix
    ./substitute.nix
    ./supermaven.nix
    ./surround.nix
    ./telescope.nix
    ./todo-comments.nix
    ./treesitter.nix
    ./trouble.nix
    ./undotree.nix
    ./which-key.nix
    ./yazi.nix
  ];
}
