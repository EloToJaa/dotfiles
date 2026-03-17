{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "unstable-2026-03-17";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "02a20337cb6cae8ffd06fbc0047c818fb2a2f999";
    hash = "sha256-q8mFEeiiyRwWWkUdNIp9jOk5aKgdtgSzckLqM3PM340=";
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
