{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-lazygit";
  version = "unstable-2025-09-03";

  src = fetchFromGitHub {
    owner = "Lil-Dank";
    repo = "lazygit.yazi";
    rev = "8f37dc5795f165021098b17d797c7b8f510aeca9";
    hash = "sha256-rR7SMTtQYrvQjhkzulDaNH/LAA77UnXkcZ50WwBX2Uw=";
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
