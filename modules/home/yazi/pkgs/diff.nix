{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-diff";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "7c174cc0ae1e07876218868e5e0917308201c081";
    hash = "sha256-RE93ZNlG6CRGZz7YByXtO0mifduh6MMGls6J9IYwaFA=";
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
