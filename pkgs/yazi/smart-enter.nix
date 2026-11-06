{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-enter";
  version = "0-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c0529fc34e4649effb79ff6f4a86aec46beebb7f";
    hash = "sha256-Wf10m6iY4xWKALLFQBOz1vgGXOQpPzryPnFS+s40QFg=";
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
