{lib, ...}: {
  perSystem = {pkgs, ...}: {
    checks.review-quick-fixes = let
      src = lib.fileset.toSource {
        root = ../.;
        fileset = lib.fileset.unions [
          ./quickfix-delete.lua
          ./review-quick-fixes.py
          ../homeModules/dev/nvim/config/keymaps.nix
        ];
      };
    in
      pkgs.runCommand "review-quick-fixes" {
        nativeBuildInputs = [pkgs.python3 pkgs.neovim];
      } ''
        export HOME=$TMPDIR
        python3 ${src}/tests/review-quick-fixes.py
        touch $out
      '';
  };
}
