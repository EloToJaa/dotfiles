{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-enter";
  version = "unstable-2025-06-23";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "42f64c01c49af5ef077672dd581f52867642f02a";
    hash = "sha256-gPiW/A94wVJWMFgtEtCst9AAxG1JmA0rOcr6lz0HA+4=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-enter.yazi/* $out
  '';

  meta = with lib; {
    description = "Open files or enter directories all in one key!";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
