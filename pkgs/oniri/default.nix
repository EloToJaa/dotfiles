{
  rustPlatform,
  fetchFromGitHub,
  lib,
  scdoc,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oniri";
  version = "1.3.6";

  src = fetchFromGitHub {
    owner = "Antiz96";
    repo = "oniri";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ha+RUaQoc1bTL67jbSL1eTXnSwP7Vy4zzlKOo+4mZ7I=";
  };

  cargoHash = "sha256-Y4yP/Cl6GRVNKCH9a4qKWLettnY6FHwmHR9zfMU8kn8=";

  nativeBuildInputs = [scdoc];

  postInstall = ''
    install -Dm644 res/completions/oniri.bash $out/share/bash-completion/completions/oniri
    install -Dm644 res/completions/oniri.fish $out/share/fish/vendor_completions.d/oniri.fish
    install -Dm644 res/completions/oniri.zsh $out/share/zsh/site-functions/_oniri
    scdoc < doc/man/oniri.1.scd > oniri.1
    install -Dm644 oniri.1 $out/share/man/man1/oniri.1
  '';

  meta = {
    description = "Automatically maximize the only window in a niri workspace";
    homepage = "https://github.com/Antiz96/oniri";
    license = lib.licenses.gpl3Plus;
    mainProgram = "oniri";
    platforms = lib.platforms.linux;
  };
})
