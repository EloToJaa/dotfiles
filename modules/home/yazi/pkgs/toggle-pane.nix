{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "unstable-2025-07-31";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "de53d90cb2740f84ae595f93d0c4c23f8618a9e4";
    hash = "sha256-ixZKOtLOwLHLeSoEkk07TB3N57DXoVEyImR3qzGUzxQ=";
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
