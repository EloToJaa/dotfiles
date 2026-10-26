{
  rustPlatform,
  fetchFromGitHub,
  lib,
  scdoc,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oniri";
  version = "1.3.10";

  src = fetchFromGitHub {
    owner = "Antiz96";
    repo = "oniri";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PQq9arUMHXg/wtbcZdA7M9BhPvddK1DcK/4433m+NVs=";
  };

  cargoHash = "sha256-BG6yfBRSN9qL+9QbXA5UHSsXRlJnJY9dAzqdd98lTmw=";

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
