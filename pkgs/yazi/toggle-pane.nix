{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "1ef5fe02a6122f8f3bb47a41056aab3f4b8598bf";
    hash = "sha256-Nz6AvWAiwdmH2HJ2vA3rMfbDDHSkXG20Ml6vc5yrjRM=";
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
