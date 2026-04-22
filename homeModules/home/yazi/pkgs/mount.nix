{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-mount";
  version = "unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "034efd687f689f1981ab0e5a7dd46c1e1b4a08c9";
    hash = "sha256-JIb26wE0WBf9Ul0wYW1/XpQICVTsNLgWgkXvtC457zo=";
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
