{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-git";
  version = "unstable-2025-05-24";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "55bf6996ada3df4cbad331ce3be0c1090769fc7c";
    hash = "sha256-v/C+ZBrF1ghDt1SXpZcDELmHMVAqfr44iWxzUWynyRk=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/git.yazi/* $out
  '';

  meta = with lib; {
    description = "Show the status of Git file changes as linemode in the file list.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/git.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
