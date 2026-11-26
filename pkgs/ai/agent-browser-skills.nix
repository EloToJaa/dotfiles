{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser-skills";
  version = "0.45.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KS1GdQJS08DVbnzSGN2py28Sgey6E7ohkBPZU4q6rho=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/skills/ $out
  '';

  meta = with lib; {
    description = " Browser automation CLI for AI agents Skills";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
})
