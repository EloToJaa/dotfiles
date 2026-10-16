{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-git";
  version = "0-unstable-2026-10-15";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "9166202cc1694c98bac3a639874d6f4c0eaa2dab";
    hash = "sha256-3ddGRQSzxyurNcyYJA+9LTLXTCjBFGATTqdkuGKixzA=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/git.yazi/* $out
  '';

  meta = with lib; {
    description = "Show the status of Git file changes as linemode in the file list.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/git.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
