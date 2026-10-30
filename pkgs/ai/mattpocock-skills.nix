{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mattpocock-skills";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ej0ATi0BWaAx+83dBwgCQxr9J2L2qEwKhUIeIRJ03Go=";
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
})
