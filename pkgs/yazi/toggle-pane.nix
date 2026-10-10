{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "6229767f7fef39a2a78f5cee9122cc4dfb43f327";
    hash = "sha256-/BNGoWziHIZ9i+RoTWGq/q3ZowNCyHGBOWiz8v2/vOE=";
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
