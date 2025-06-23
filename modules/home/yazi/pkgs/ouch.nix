{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-ouch";
  version = "unstable-2025-06-23";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "1ee69a56da3c4b90ec8716dd9dd6b82e7a944614";
    hash = "sha256-4KZeDkMXlhUV0Zh+VGBtz9kFPGOWCexYVuKUSCN463o=";
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
