{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-mount";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "896fa5aec1db0163e2f65d07a130d064de53b0b2";
    hash = "sha256-0nD3jSkUt7mcsfPnJ3yBwdJYRY6JVSxVAj4eXEgBWus=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/mount.yazi/* $out
  '';

  meta = with lib; {
    description = "A mount manager for Yazi, providing disk mount, unmount, and eject functionality.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/mount.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
