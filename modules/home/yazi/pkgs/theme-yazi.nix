{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-yazi";
  version = "unstable-2025-05-17";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "fca8e93e0a408671fa54cc0cb103e76b85e8c011";
    hash = "sha256-ILaPj84ZlNc6MBwrpwBDNhGhXge9mPse4FYdSMU4eO8=";
  };

  buildPhase = ''
    mkdir $out
    ln -s $src/themes/mocha/catppuccin-mocha-blue.toml $out/theme.toml
  '';

  meta = with lib; {
    description = "Theme for yazi";
    homepage = "https://github.com/catppuccin/yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
