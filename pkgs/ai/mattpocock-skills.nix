{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "mattpocock-skills";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "9c9f36ccd3995266cd675468af71639c8dde1ec5";
    hash = "sha256-CJNC5fORkc+FGd+FlCXG6rZcVv2MCqCNHCVC0AW623Q=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Skills for Real Engineers.";
    homepage = "https://github.com/mattpocock/skills";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
