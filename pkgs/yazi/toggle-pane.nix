{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "0-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c0529fc34e4649effb79ff6f4a86aec46beebb7f";
    hash = "sha256-Wf10m6iY4xWKALLFQBOz1vgGXOQpPzryPnFS+s40QFg=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/toggle-pane.yazi/* $out
  '';

  meta = with lib; {
    description = "Toggle the show, hide, and maximize states for different panes: parent, current, and preview. It respects the user's ratio settings!";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/toggle-pane.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
