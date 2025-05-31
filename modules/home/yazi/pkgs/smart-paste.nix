{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-paste";
  version = "unstable-2025-05-31";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c0ad8a3c995e2e71c471515b9cf17d68c8425fd7";
    hash = "sha256-WC/5FNzZiGxl9HKWjF+QMEJC8RXqT8WtOmjVH6kBqaY=";
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
