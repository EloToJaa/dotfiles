{pkgs, ...}: {
  programs.waybar = {
    enable = true;
    package = pkgs.unstable.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
    });
  };
}
