{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "0.1.275-unstable-2026-10-12";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "664101c02e7321286f8d8db5f92e840dc939bff8";
    hash = "sha256-FXMxDt/50t9MemSae8xswZf0R3QVX+KgxjV6TgMdlIA=";
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
