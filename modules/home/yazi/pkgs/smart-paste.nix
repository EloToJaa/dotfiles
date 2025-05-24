{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-paste";
  version = "unstable-2025-05-24";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "55bf6996ada3df4cbad331ce3be0c1090769fc7c";
    hash = "sha256-v/C+ZBrF1ghDt1SXpZcDELmHMVAqfr44iWxzUWynyRk=";
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
