{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-toggle-pane";
  version = "0-unstable-2026-11-09";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "70e03737ef91546e33114f94eabaad90d3b75c5f";
    hash = "sha256-a4oddfENYnRD1AhDSBPBRMHgl+MPFnWELuO5uepOsqA=";
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
