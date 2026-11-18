{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "tstack-skills";
  version = "0-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "t3dotgg";
    repo = "tstack";
    rev = "11e37a74d0a6868c121cd0910ab2b3bd9873b92a";
    hash = "sha256-1N0fxvcM44NcGOZeYJiX/EAJuI9GoAj5rEXmu7mJc3w=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "The agent skills Theo uses every day";
    homepage = "https://github.com/t3dotgg/tstack";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
