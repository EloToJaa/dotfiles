{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "agent-browser-skills";
  version = "0.39.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Og2ruMaY+ObT9WiYqCyoXAcwZ/6t2g6SeU3+wF15ck=";
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
