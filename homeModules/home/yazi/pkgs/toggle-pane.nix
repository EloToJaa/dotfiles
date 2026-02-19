{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "unstable-2026-02-19";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "25918dcde97f11ac37f80620cc264680aedc4df8";
    hash = "sha256-TzHJNIFZjUOImZ4dRC0hnB4xsDZCOuEjfXRi2ZXr8QE=";
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
