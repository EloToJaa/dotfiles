{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mattpocock-skills";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/mAmj7QFdyOWhLmy3Rt2/Hfsh5qwirTRax7hmQffFdo=";
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
