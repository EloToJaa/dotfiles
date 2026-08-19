{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "anthropics-skills";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "0a64e398ec6bb34a494f0c347e8ccae53a862f8e";
    hash = "sha256-0ZtHTJVHeW8jIprKgCo/yU2ZI2cZxUqD3Riet3UWdt8=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Public repository for Agent Skills";
    homepage = "https://github.com/anthropics/skills";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
