{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-mount";
  version = "0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "6229767f7fef39a2a78f5cee9122cc4dfb43f327";
    hash = "sha256-/BNGoWziHIZ9i+RoTWGq/q3ZowNCyHGBOWiz8v2/vOE=";
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
