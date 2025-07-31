{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-lazygit";
  version = "unstable-2025-07-31";

  src = fetchFromGitHub {
    owner = "Lil-Dank";
    repo = "lazygit.yazi";
    rev = "7a08a0988c2b7481d3f267f3bdc58080e6047e7d";
    hash = "sha256-OJJPgpSaUHYz8a9opVLCds+VZsK1B6T+pSRJyVgYNy8=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Plugin for Yazi to manage git repos with lazygit";
    homepage = "https://github.com/Lil-Dank/lazygit.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
