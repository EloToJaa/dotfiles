{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-relative-motions";
  version = "unstable-2025-04-28";

  src = fetchFromGitHub {
    owner = "dedukun";
    repo = "relative-motions.yazi";
    rev = "ce2e890227269cc15cdc71d23b35a58fae6d2c27";
    hash = "sha256-Ijz1wYt+L+24Fb/rzHcDR8JBv84z2UxdCIPqTdzbD14=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin based about vim motions.";
    homepage = "https://github.com/dedukun/relative-motions.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
