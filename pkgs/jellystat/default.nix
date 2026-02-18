{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "jellystat";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "CyferShepard";
    repo = "jellystat";
    tag = finalAttrs.version;
    hash = lib.fakeHash;
  };

  npmDepsHash = lib.fakeHash;

  # If https://github.com/CyferShepard/Jellystat/pull/346 is ever merged, this can be removed
  # Required for the ability to configure a port in the systemd-service / nixos module
  patches = [./js-port-env-var.patch];

  preInstall = ''
    mkdir $out
    mkdir $out/backend
  '';

  installPhase = ''
    runHook preInstall

    cp -R ./dist $out/dist
    cp -R ./node_modules $out
    cp -R $src/backend/ $out

    # $out/backend/server.js requires ../../package.json
    cp package.json $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Free and open source Statistics App for Jellyfin";
    homepage = "https://github.com/CyferShepard/Jellystat";
    changelog = "https://github.com/CyferShepard/Jellystat/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.kashw2];
  };
})
