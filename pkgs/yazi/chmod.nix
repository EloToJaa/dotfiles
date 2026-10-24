{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-chmod";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "e0bbd205de9759e7aa81857e1ff616eb5123e305";
    hash = "sha256-H/4Oi/D2M/aDEk/AourPURxfhoMxSm5UjaRgpeXrQ1Q=";
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
