{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-filter";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "5d5c4803dd12bab4e4f19d606f8db0c871e6bec5";
    hash = "sha256-cZlnrlgv8+SFeNgIW69q//i/apcpvAv41q5W8bJwVaI=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-filter.yazi/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin that makes filters smarter: continuous filtering, automatically enter unique directory, open file on submitting.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
