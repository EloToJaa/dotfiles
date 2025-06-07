{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-ouch";
  version = "unstable-2025-06-07";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "10b462765f37502065555e83c68a72bb26870fe2";
    hash = "sha256-mtXl76a54Deg4cyrD0wr++sD/5b/kCsnJ+ngM6OokTc=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
