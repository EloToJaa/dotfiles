{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-relative-motions";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "dedukun";
    repo = "relative-motions.yazi";
    rev = "9d26460e781a254f59e2b8d460829796534f8fce";
    hash = "sha256-xoqUwmw6DUUGUbkmJye3b4IH7Kp0ZSOYYMCjJ9e7E68=";
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
