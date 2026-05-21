{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "f234924ce5c179e597827fab5712e48113335426";
    hash = "sha256-jzEU7Ng7eAUVIYQHgWI320/lmgauuxr9JOfLHfYu1K0=";
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
