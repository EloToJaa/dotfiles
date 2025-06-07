{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-copy-file-contents";
  version = "unstable-2025-06-07";

  src = fetchFromGitHub {
    owner = "Anirudhg07";
    repo = "plugins-yazi";
    rev = "907e292401d764c571ca3acdeaa294a4b6dd8036";
    hash = "sha256-DmdEcmBdMNNVte++UlQacz+ITYC1l55q2tJWKZjXHBc=";
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
