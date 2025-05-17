{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-hexyl";
  version = "unstable-2025-05-17";

  src = fetchFromGitHub {
    owner = "Reledia";
    repo = "hexyl.yazi";
    rev = "016a09bcc249dd3ce06267d54cc039e73de9c647";
    hash = "sha256-ly/cLKl2y3npoT2nX8ioGOFcRXI4UXbD9Es/5veUhOU=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Preview any file on Yazi using hexyl";
    homepage = "https://github.com/Reledia/hexyl.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
