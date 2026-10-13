{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "yaziPlugins-ouch";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t1kUo4+YODeTG9d5Yq/vxElcmRHIebC5TRv+uDGG88c=";
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
})
