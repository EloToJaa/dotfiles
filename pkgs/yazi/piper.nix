{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-piper";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "e0bbd205de9759e7aa81857e1ff616eb5123e305";
    hash = "sha256-H/4Oi/D2M/aDEk/AourPURxfhoMxSm5UjaRgpeXrQ1Q=";
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
