{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-exifaudio";
  version = "unstable-2025-08-10";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "4506f9d5032e714c0689be09d566dd877b9d464e";
    hash = "sha256-RWCqWBpbmU3sh/A+LBJPXL/AY292blKb/zZXGvIA5/o=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Preview audio files metadata on yazi ";
    homepage = "Preview audio files metadata on yazi ";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
