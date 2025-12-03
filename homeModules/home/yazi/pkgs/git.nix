{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-git";
  version = "unstable-2025-12-03";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "eaf6920b7439fa7164a1c162a249c3c76dc0acd9";
    hash = "sha256-B6zhZfp3SEaiviIzosI2aD8fk+hQF0epOTKi1qm8V3E=";
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
