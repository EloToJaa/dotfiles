{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "0.1.272-unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "86c1c1785b2f883bb5650d1656551e769118255e";
    hash = "sha256-Y2GxRL3aoM7f3u7kwoCd73bNJ3bX065L4dD+OKK2OKk=";
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
