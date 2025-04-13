{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-fr";
  version = "unstable-2025-04-13";

  src = fetchFromGitHub {
    owner = "lpnh";
    repo = "fr.yazi";
    rev = "92edf0b4bfce831d6b3178117b1aa7d8557f424e";
    hash = "sha256-6PEKX9IOAZwuoTnPXH7UnCOcnmyKsE/gKvkm0T3cS74=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Yazi plugin that integrates fzf with bat preview for rg search and rga preview for rga search";
    homepage = "https://github.com/lpnh/fr.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
