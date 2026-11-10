{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-filter";
  version = "0-unstable-2026-11-09";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "70e03737ef91546e33114f94eabaad90d3b75c5f";
    hash = "sha256-a4oddfENYnRD1AhDSBPBRMHgl+MPFnWELuO5uepOsqA=";
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
