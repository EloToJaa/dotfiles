{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "open-code-review-skills";
  version = "1.12.13-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    rev = "357c3f09a264563ab64d8f4fc3b25b186cd3c4a4";
    hash = "sha256-fLYgY7oh/D9e1SxDnpnDcTBZzIi9V/fVFfe/8Z34BoI=";
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
}
