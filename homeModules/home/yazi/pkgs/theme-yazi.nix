{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-yazi";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "41f24ed142e34109a9a65a5dfe58c1b4eb6d2fd9";
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
