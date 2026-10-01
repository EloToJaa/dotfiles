{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-yazi";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "baaf5d1c9427b836fbefd126aa855f9eab7a9d0d";
    hash = "sha256-L6SApM07CSQk0znEsFP8WaxW+ZHcindXo612r1XcwIg=";
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
