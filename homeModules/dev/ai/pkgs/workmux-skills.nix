{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "workmux-skills";
  version = "unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "workmux";
    rev = "57efd749f44232d7f8fb9b6b46708406075b7de9";
    hash = "sha256-xppT1/ks4nPDRGCcUr7LhGfJPHG9F+NuqLSzOISBgBI=";
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
