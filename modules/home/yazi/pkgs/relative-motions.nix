{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-relative-motions";
  version = "unstable-2025-08-12";

  src = fetchFromGitHub {
    owner = "dedukun";
    repo = "relative-motions.yazi";
    rev = "a603d9ea924dfc0610bcf9d3129e7cba605d4501";
    hash = "sha256-9i6x/VxGOA3bB3FPieB7mQ1zGaMK5wnMhYqsq4CvaM4=";
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
