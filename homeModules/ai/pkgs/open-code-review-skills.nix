{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "open-code-review-skills";
  version = "unstable-2026-09-29";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    rev = "f93ff155ddac3b22a9290cddc1645b91ca15eb2d";
    hash = "sha256-eJ3veLx8292mGSZFXZht6pnCEsqvn79hkXsuXO8jzUk=";
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
