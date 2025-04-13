{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-hexyl";
  version = "unstable-2025-04-13";

  src = fetchFromGitHub {
    owner = "Reledia";
    repo = "hexyl.yazi";
    rev = "228a9ef2c509f43d8da1847463535adc5fd88794";
    hash = "sha256-Xv1rfrwMNNDTgAuFLzpVrxytA2yX/CCexFt5QngaYDg=";
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
