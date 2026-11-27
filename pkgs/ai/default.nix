{pkgs, ...}: {
  ai-pi-agent-extensions = pkgs.callPackage ./pi-agent-extensions.nix {};
  ai-pi-vim = pkgs.callPackage ./pi-vim.nix {};
}
