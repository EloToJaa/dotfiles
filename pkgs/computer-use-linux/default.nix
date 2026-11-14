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
  version = "0.7.53";

  src = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-59IHxzSNBg/HmdNi5JGyP3f80+RXWfzJ8JRQ3MpWdlM=";
  };

  cargoHash = "sha256-u91WO1EIRYdpxAeKyzaumgfenMrF4S+wg+U+xXvP1Gs=";

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
