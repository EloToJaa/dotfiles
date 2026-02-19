{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-diff";
  version = "unstable-2026-02-19";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "25918dcde97f11ac37f80620cc264680aedc4df8";
    hash = "sha256-TzHJNIFZjUOImZ4dRC0hnB4xsDZCOuEjfXRi2ZXr8QE=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/diff.yazi/* $out
  '';

  meta = with lib; {
    description = "Diff the selected file with the hovered file, create a living patch, and copy it to the clipboard.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/diff.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
