{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-git";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "7c174cc0ae1e07876218868e5e0917308201c081";
    hash = "sha256-RE93ZNlG6CRGZz7YByXtO0mifduh6MMGls6J9IYwaFA=";
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
