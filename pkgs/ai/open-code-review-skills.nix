{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "open-code-review-skills";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qRUlkbhGSPv+nxV4yig7EiQ6tNVyGMivm30qZd+TQwc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/skills
    cp -r $src/skills/open-code-review $out/skills/
  '';

  meta = with lib; {
    description = "Open Code Review agent skill";
    homepage = "https://github.com/alibaba/open-code-review";
    license = licenses.asl20;
    maintainers = [];
    platforms = platforms.all;
  };
})
