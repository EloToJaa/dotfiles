{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "896fa5aec1db0163e2f65d07a130d064de53b0b2";
    hash = "sha256-0nD3jSkUt7mcsfPnJ3yBwdJYRY6JVSxVAj4eXEgBWus=";
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
