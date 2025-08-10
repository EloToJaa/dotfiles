{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-diff";
  version = "unstable-2025-08-10";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "de53d90cb2740f84ae595f93d0c4c23f8618a9e4";
    hash = "sha256-ixZKOtLOwLHLeSoEkk07TB3N57DXoVEyImR3qzGUzxQ=";
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
