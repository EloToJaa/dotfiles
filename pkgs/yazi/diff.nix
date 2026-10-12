{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-diff";
  version = "0-unstable-2026-10-11";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "603fa36d554750a827bbdb3b4d5f779c5b066c38";
    hash = "sha256-DfcN2VU+8iQazgT9MXm2dj7742W5fhScSm1FEkd/5Tk=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/diff.yazi/* $out
  '';

  meta = with lib; {
    description = "Diff the selected file with the hovered file, create a living patch, and copy it to the clipboard.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/diff.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
