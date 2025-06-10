{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-exifaudio";
  version = "unstable-2025-06-10";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "e766cd273246612fe71fc18d2126619a41273c32";
    hash = "sha256-aniuY14pXcoaW6YkUwt7hTl9mWjl5HoOPhHkuY4ooAw=";
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
