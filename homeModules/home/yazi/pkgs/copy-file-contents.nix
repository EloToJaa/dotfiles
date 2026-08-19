{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-copy-file-contents";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "Anirudhg07";
    repo = "plugins-yazi";
    rev = "3f4f1a3ea58707ce87b6455ebc25e7954b261e43";
    hash = "sha256-hNw+1BRVHPR1LgUE6MYtnJEAO4fhSI3m+3M8wzw53UQ=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/copy-file-contents.yazi/* $out
  '';

  meta = with lib; {
    description = "Copy the contents of a file to clipboard directly from Yazi.";
    homepage = "https://github.com/AnirudhG07/plugins-yazi/tree/main/copy-file-contents.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
