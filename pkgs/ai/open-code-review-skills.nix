{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "open-code-review-skills";
  version = "1.12.13-unstable-2026-10-13";

  src = fetchFromGitHub {
    owner = "alibaba";
    repo = "open-code-review";
    rev = "c7734212e1bb2aa6049c0c26bbbb8fd23ffd1134";
    hash = "sha256-qQbIn/wZHBk/M0AHKhgG1+VEwUZ3ZPrQuYK0BE5L54Y=";
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
