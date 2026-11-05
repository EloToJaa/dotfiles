{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-filter";
  version = "0-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "0f28df231639070014ab7fc828c5000d9e3634f5";
    hash = "sha256-02Pb7uSqD5CjgLU2qmXNutMMFkNxm88lNP7R5GUMuOI=";
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
