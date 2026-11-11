{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-piper";
  version = "0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "1ef5fe02a6122f8f3bb47a41056aab3f4b8598bf";
    hash = "sha256-Nz6AvWAiwdmH2HJ2vA3rMfbDDHSkXG20Ml6vc5yrjRM=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/piper.yazi/* $out
  '';

  meta = with lib; {
    description = "Pipe any shell command as a previewer.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/piper.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
