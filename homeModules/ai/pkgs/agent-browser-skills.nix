{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "agent-browser-skills";
  version = "unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "b4f2f37d7b4f954022bc77f8d6dce70e07072b00";
    hash = "sha256-mPtY6X0WwtX6pna47aQr4Rn+dLIWbMzXkObpUTp6Zy8=";
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
}
