{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-git";
  version = "0-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c0529fc34e4649effb79ff6f4a86aec46beebb7f";
    hash = "sha256-Wf10m6iY4xWKALLFQBOz1vgGXOQpPzryPnFS+s40QFg=";
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
