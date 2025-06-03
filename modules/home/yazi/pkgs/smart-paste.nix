{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-paste";
  version = "unstable-2025-06-04";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "63f9650e522336e0010261dcd0ffb0bf114cf912";
    hash = "sha256-ZCLJ6BjMAj64/zM606qxnmzl2la4dvO/F5QFicBEYfU=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-paste.yazi/* $out
  '';

  meta = with lib; {
    description = "Paste files into the hovered directory or to the CWD if hovering over a file.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-paste.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
