{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-agent-extensions";
  version = "unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "rytswd";
    repo = "pi-agent-extensions";
    rev = "2380efc4b3f8789dfce8ee2317ce5d7c50d0d10e";
    hash = "sha256-MHmOkbm/BeRwu2amrU6ABdtNtpoWfonVRXXAcQm/TEs=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Pi agent extensions";
    homepage = "https://github.com/rytswd/pi-agent-extensions";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
