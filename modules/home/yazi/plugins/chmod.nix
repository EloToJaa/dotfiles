{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-chmod";
  version = "unstable-2025-04-25";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "4b027c79371af963d4ae3a8b69e42177aa3fa6ee";
    hash = "sha256-auGNSn6tX72go7kYaH16hxRng+iZWw99dKTTUN91Cow=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/chmod.yazi/* $out
  '';

  meta = with lib; {
    description = "Execute chmod on the selected files to change their mode.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/chmod.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
