{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-enter";
  version = "unstable-2026-02-19";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "25918dcde97f11ac37f80620cc264680aedc4df8";
    hash = "sha256-TzHJNIFZjUOImZ4dRC0hnB4xsDZCOuEjfXRi2ZXr8QE=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-enter.yazi/* $out
  '';

  meta = with lib; {
    description = "Open files or enter directories all in one key!";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
