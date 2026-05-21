{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-agent-extensions";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "rytswd";
    repo = "pi-agent-extensions";
    rev = "2dcb77a2caaf247699d3804eef3b02614b008ccf";
    hash = "sha256-2zX7bt+gI6GUG7l1RveanBwYJI1RwkbLJeZRonYnUMA=";
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
