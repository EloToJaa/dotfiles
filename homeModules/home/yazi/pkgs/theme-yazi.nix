{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-yazi";
  version = "unstable-2026-02-19";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "fc69d6472d29b823c4980d23186c9c120a0ad32c";
    hash = "sha256-Og33IGS9pTim6LEH33CO102wpGnPomiperFbqfgrJjw=";
  };

  buildPhase = ''
    cp $src/themes/mocha/catppuccin-mocha-blue.toml $out
  '';

  meta = with lib; {
    description = "Theme for yazi";
    homepage = "https://github.com/catppuccin/yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
