{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-copy-file-contents";
  version = "unstable-2025-05-31";

  src = fetchFromGitHub {
    owner = "Anirudhg07";
    repo = "plugins-yazi";
    rev = "49975aeee89c50433040f504849cadd4373f6cf0";
    hash = "sha256-MuPXWi+bPumNrnVctG9qVb0YLBVmiVEK0cVwsQzFDVM=";
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
