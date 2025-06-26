{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "7c174cc0ae1e07876218868e5e0917308201c081";
    hash = "sha256-RE93ZNlG6CRGZz7YByXtO0mifduh6MMGls6J9IYwaFA=";
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
