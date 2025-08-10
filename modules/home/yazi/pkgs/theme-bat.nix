{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziTheme-bat";
  version = "unstable-2025-08-10";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "bat";
    rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
    hash = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
  };

  buildPhase = ''
    cp "$src/themes/Catppuccin Mocha.tmTheme" $out
  '';

  meta = with lib; {
    description = "Theme for the yazi file previewer from bat";
    homepage = "https://github.com/catppuccin/bat";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
