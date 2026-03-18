{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "unstable-2026-03-18";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "a0ceadc3a794c1ffcedc920bd535dd99b9b746bb";
    hash = "sha256-blMSGNi7pe4tDMW2t7J2upJyFR1aSanCyCvnPcHqRkA=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/skills/ $out
    cp -r $src/.opencode/ $out
  '';

  meta = with lib; {
    description = "git worktrees + tmux windows for zero-friction parallel dev";
    homepage = "https://workmux.raine.dev/";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
