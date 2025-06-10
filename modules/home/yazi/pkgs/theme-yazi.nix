{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-yazi";
  version = "unstable-2025-06-10";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "1a8c939e47131f2c4bd07a2daea7773c29e2a774";
    hash = "sha256-hjqmNxIr/KCN9k5ZT7O994BeWdp56NP7aS34+nZ/fQQ=";
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
