{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-chmod";
  version = "0-unstable-2026-10-11";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "603fa36d554750a827bbdb3b4d5f779c5b066c38";
    hash = "sha256-DfcN2VU+8iQazgT9MXm2dj7742W5fhScSm1FEkd/5Tk=";
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
