{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-ouch";
  version = "unstable-2025-07-10";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "bb941c4891b21762f98318a6ad484827726019e6";
    hash = "sha256-g/ZHArXksRo49k9UBHap0CXzIdycQigjbdCzDK1VaLY=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
