{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-filter";
  version = "unstable-2025-04-25";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "4b027c79371af963d4ae3a8b69e42177aa3fa6ee";
    hash = "sha256-auGNSn6tX72go7kYaH16hxRng+iZWw99dKTTUN91Cow=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-filter.yazi/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin that makes filters smarter: continuous filtering, automatically enter unique directory, open file on submitting.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
