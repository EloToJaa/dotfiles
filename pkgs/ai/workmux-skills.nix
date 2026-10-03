{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "35433457d2ebcda07f9f05a5d996fb462f558ab3";
    hash = "sha256-4Sxl0J/uSpuet/W5icSTe7uEDjd3DoNGiTdqvWlOMqM=";
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
