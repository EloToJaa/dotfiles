{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-chmod";
  version = "0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "25d992d7de29a6fbaeff8d3b27007a33225cd118";
    hash = "sha256-ihkKeOQ7HG/oS1DSYLDOifmhzY9nqEu6xC+DtrpzR3w=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/chmod.yazi/* $out
  '';

  meta = with lib; {
    description = "Execute chmod on the selected files to change their mode.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/chmod.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
