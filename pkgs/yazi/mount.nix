{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-mount";
  version = "0-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "0f28df231639070014ab7fc828c5000d9e3634f5";
    hash = "sha256-02Pb7uSqD5CjgLU2qmXNutMMFkNxm88lNP7R5GUMuOI=";
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
