{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-piper";
  version = "unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "c2c16c83dd6c754c38893030848a162bb2422ca2";
    hash = "sha256-BdisAHsLHNqtuDu8rtBZZaqiTeL60pQOWKsRct35VZM=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/piper.yazi/* $out
  '';

  meta = with lib; {
    description = "Pipe any shell command as a previewer.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/piper.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
