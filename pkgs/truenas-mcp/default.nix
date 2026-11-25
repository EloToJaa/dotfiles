{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "truenas-mcp";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "truenas";
    repo = "truenas-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GgZ8I4kRxJNrctqSg/PxAaksgdekQPL3bD4+eK2wCIU=";
  };

  vendorHash = "sha256-RCcyGLepRB1YMTb6hvAyskYTzHrKlwqjRdnRLfdydls=";

  subPackages = ["cmd/truenas-mcp"];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "MCP server for TrueNAS";
    homepage = "https://github.com/truenas/truenas-mcp";
    changelog = "https://github.com/truenas/truenas-mcp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "truenas-mcp";
    platforms = lib.platforms.linux;
  };
})
