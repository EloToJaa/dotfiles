{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-ouch";
  version = "unstable-2026-01-28";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "594b8a2b246633d46b03a3261c9aebd1c4b5abf3";
    hash = "sha256-+M0ZFh2jKts5GP9KgKsbpeNe0ldXQGyUZlYjDbp4yhw=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
