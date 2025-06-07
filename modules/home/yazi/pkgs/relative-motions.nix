{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-relative-motions";
  version = "unstable-2025-06-07";

  src = fetchFromGitHub {
    owner = "dedukun";
    repo = "relative-motions.yazi";
    rev = "2e3b6172e6226e0db96aea12d09dea2d2e443fea";
    hash = "sha256-v0e06ieBKNmt9DATdL7R4AyVFa9DlNBwpfME3LHozLA=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin based about vim motions.";
    homepage = "https://github.com/dedukun/relative-motions.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
