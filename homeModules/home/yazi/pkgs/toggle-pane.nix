{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "034efd687f689f1981ab0e5a7dd46c1e1b4a08c9";
    hash = "sha256-JIb26wE0WBf9Ul0wYW1/XpQICVTsNLgWgkXvtC457zo=";
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
