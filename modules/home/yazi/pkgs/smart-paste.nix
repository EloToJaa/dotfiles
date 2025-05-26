{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-paste";
  version = "unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "4df8f70eb643963f6b2d32045342fee311ea95fd";
    hash = "sha256-PZcVDFuU8cQ8QO8nmwlHpDbT3p61shtREHnJZoC7oPI=";
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
