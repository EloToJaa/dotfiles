{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-exifaudio";
  version = "unstable-2025-05-10";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "7ff714155f538b6460fdc8e911a9240674ad9b89";
    hash = "sha256-qRUAKlrYWV0qzI3SAQUYhnL3QR+0yiRc+0XbN/MyufI=";
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
