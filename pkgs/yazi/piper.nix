{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-piper";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "6f26ae04ba2e4763faada6a7997ae8b57c158cdb";
    hash = "sha256-pySI+LxiGmGEp/cvVXtuOuNzvy3c2QC6zuoTjActPbw=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/piper.yazi/* $out
  '';

  meta = with lib; {
    description = "Pipe any shell command as a previewer.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/piper.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
