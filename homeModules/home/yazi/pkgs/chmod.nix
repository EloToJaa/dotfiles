{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-chmod";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "5d5c4803dd12bab4e4f19d606f8db0c871e6bec5";
    hash = "sha256-cZlnrlgv8+SFeNgIW69q//i/apcpvAv41q5W8bJwVaI=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/chmod.yazi/* $out
  '';

  meta = with lib; {
    description = "Execute chmod on the selected files to change their mode.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/chmod.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
