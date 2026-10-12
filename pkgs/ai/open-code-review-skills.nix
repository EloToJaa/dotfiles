{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "open-code-review-skills";
  version = "1.12.13-unstable-2026-10-12";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    rev = "f32dace4dc5674bcb3f6ef0aefd5a9522e07e873";
    hash = "sha256-IDfuP8JNxNr1M6o/kHR+6a1HPNmBgGZrYquoFRs69P8=";
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
