{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  xdotool,
  wmctrl,
  xprop,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.7.60";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k/Z5ZG91/NIo18VFDoMSBeMOh8WI1fWskpDvxRo0SPc=";
  };

  cargoHash = "sha256-u4VAVSAfIxwoS+rsArCBWJO1Rv8uNNP1p14Bat2rd2E=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  # Tests need a live desktop session
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/computer-use-linux \
      --prefix PATH : ${lib.makeBinPath [xdotool wmctrl xprop]}
  '';

  meta = {
    description = "Linux desktop control for AI agents over MCP: AT-SPI trees, screenshots, window targeting and input";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    license = lib.licenses.mit;
    mainProgram = "computer-use-linux";
    platforms = lib.platforms.linux;
  };
})
