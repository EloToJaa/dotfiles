{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "workmux-skills";
  version = "0.1.280";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zrjuq/6WrY4qlkxymtDloLW2WhsZnGKj6W3iCrPk0Ow=";
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
