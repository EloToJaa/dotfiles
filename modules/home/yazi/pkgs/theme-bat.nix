{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-bat";
  version = "unstable-2025-05-17";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "bat";
    rev = "699f60fc8ec434574ca7451b444b880430319941";
    hash = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
  };

  buildPhase = ''
    mkdir $out
    ln -s "$src/themes/Catppuccin Mocha.tmTheme" $out/Catppuccin-mocha.tmTheme
  '';

  meta = with lib; {
    description = "Theme for the yazi file previewer from bat";
    homepage = "https://github.com/catppuccin/bat";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
