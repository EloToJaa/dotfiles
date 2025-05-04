{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-diff";
  version = "unstable-2025-05-04";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "864a0210d9ba1e8eb925160c2e2a25342031d8d3";
    hash = "sha256-m3709h7/AHJAtoJ3ebDA40c77D+5dCycpecprjVqj/k=";
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
