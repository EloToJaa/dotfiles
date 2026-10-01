{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-ouch";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "8e70ec74efbec63c7d7db3b1e567b56763affc09";
    hash = "sha256-CSthsFIiIa81xHgs2Szoy9atRouRESHOPxUt/pOtvl0=";
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
