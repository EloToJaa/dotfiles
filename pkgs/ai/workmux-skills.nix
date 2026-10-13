{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "workmux-skills";
  version = "0.1.275";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    tag = "v${finalAttrs.version}";
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
})
