{
  lib,
  makeWrapper,
  pkgs,
  pyproject-build-systems,
  pyproject-nix,
  python313,
  uv2nix,
  unifi-mcp-src,
}: let
  version = "0.50.3";
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = unifi-mcp-src;
  };
  # nixpkgs wraps uv with UV_SYSTEM_CERTS=1, which fails in the sandbox where no CA certs exist
  uv = pkgs.runCommand "uv-no-system-certs" {nativeBuildInputs = [makeWrapper];} ''
    makeWrapper ${pkgs.buildPackages.uv}/bin/uv $out/bin/uv --set UV_SYSTEM_CERTS 0
  '';
  pythonSet = (pkgs.callPackage pyproject-nix.build.packages {python = python313;}).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.default
      (workspace.mkPyprojectOverlay {sourcePreference = "wheel";})
      (final: prev: {
        antlr4-python3-runtime = prev.antlr4-python3-runtime.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem {setuptools = [];};
        });
        pyprojectBuildHook = prev.pyprojectBuildHook.override {inherit uv;};
        pyprojectInstallHook = prev.pyprojectInstallHook.override {inherit uv;};
        unifi-network-mcp = prev.unifi-network-mcp.overrideAttrs (old: {
          env = (old.env or {}) // {SETUPTOOLS_SCM_PRETEND_VERSION = version;};
        });
      })
    ]
  );
  venv = pythonSet.mkVirtualEnv "unifi-network-mcp-env" {unifi-network-mcp = [];};
in
  pkgs.runCommand "unifi-network-mcp-${version}" {
    inherit version;
    pname = "unifi-network-mcp";
    nativeBuildInputs = [makeWrapper];
    meta = {
      description = "MCP server for the UniFi Network application";
      homepage = "https://github.com/sirkirby/unifi-mcp";
      changelog = "https://github.com/sirkirby/unifi-mcp/releases/tag/network/v${version}";
      license = lib.licenses.mit;
      mainProgram = "unifi-network-mcp";
      platforms = lib.platforms.linux;
    };
  } ''
    makeWrapper ${venv}/bin/unifi-network-mcp $out/bin/unifi-network-mcp
  ''
