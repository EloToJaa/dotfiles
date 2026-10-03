{pkgs, ...}: {
  ai-agent-browser-skills = pkgs.callPackage ./agent-browser-skills.nix {};
  ai-anthropics-skills = pkgs.callPackage ./anthropics-skills.nix {};
  ai-mattpocock-skills = pkgs.callPackage ./mattpocock-skills.nix {};
  ai-open-code-review-skills = pkgs.callPackage ./open-code-review-skills.nix {};
  ai-pi-agent-extensions = pkgs.callPackage ./pi-agent-extensions.nix {};
  ai-pi-vim = pkgs.callPackage ./pi-vim.nix {};
  ai-workmux-skills = pkgs.callPackage ./workmux-skills.nix {};
}
