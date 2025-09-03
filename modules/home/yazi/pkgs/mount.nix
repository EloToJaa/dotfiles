{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-mount";
  version = "unstable-2025-09-03";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "d7588f6d29b5998733d5a71ec312c7248ba14555";
    hash = "sha256-9+58QhdM4HVOAfEC224TrPEx1N7F2VLGMxKVLAM4nJw=";
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
