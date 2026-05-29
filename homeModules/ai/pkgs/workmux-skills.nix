{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "d3f7930bfa9026aecdca12509bee2c93553badf6";
    hash = "sha256-v7COjgmFY2n26NwTLQWc8qeGqJHdPO1DtpCTwRNe5Sk=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/skills/ $out
    cp -r $src/resources/opencode/ $out
  '';

  meta = with lib; {
    description = "git worktrees + tmux windows for zero-friction parallel dev";
    homepage = "https://workmux.raine.dev/";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
