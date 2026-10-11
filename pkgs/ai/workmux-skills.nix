{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "0.1.272-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "0b741a985c1b879b76c4b2520d3b74af0d24bb93";
    hash = "sha256-Y2EfE0MTmKTctaNjLsGu3hQhNKY5XXbQvG6MYgdU12s=";
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
