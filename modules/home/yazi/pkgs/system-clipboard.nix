{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-system-clipboard";
  version = "unstable-2025-09-10";

  src = fetchFromGitHub {
    owner = "orhnk";
    repo = "system-clipboard.yazi";
    rev = "4f6942dd5f0e143586ab347d82dfd6c1f7f9c894";
    hash = "sha256-M7zKUlLcQA3ihpCAZyOkAy/SzLu31eqHGLkCSQPX1dY=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Cross platform implementation of a simple system clipboard for yazi file manager";
    homepage = "https://github.com/orhnk/system-clipboard.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
