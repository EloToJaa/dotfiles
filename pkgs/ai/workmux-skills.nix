{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "workmux-skills";
  version = "0.1.282";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pcS9uL918u9A8zcWoQrzLVC/pjchq1MzV4h3CA99OdA=";
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
