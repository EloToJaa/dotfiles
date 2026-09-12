{
  lib,
  stdenv,
  autoPatchelfHook,
  bun,
  bun2nix,
  fetchFromGitHub,
  makeWrapper,
  nodejs_22,
  openssl,
  runCommand,
  ...
}: let
  version = "2.18.1";
  upstreamSrc = fetchFromGitHub {
    owner = "fredrikburmester";
    repo = "streamystats";
    tag = "v${version}";
    hash = "sha256-ugjH1MT4glCRvZmdqXnn7eteyxWiME6pvX7kKuKn+38=";
  };
  src = runCommand "streamystats-${version}-source" {} ''
    cp -R ${upstreamSrc}/. $out
    chmod -R u+w $out
    cp ${./bun.nix} $out/bun.nix
  '';
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "streamystats";
    inherit version src;

    bunDeps = bun2nix.fetchBunDeps {
      bunNix = "${src}/bun.nix";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      bun
      bun2nix.hook
      makeWrapper
    ];

    buildInputs = [
      openssl
      stdenv.cc.cc.lib
    ];

    env = {
      NEXT_PUBLIC_VERSION = finalAttrs.version;
      NEXT_TELEMETRY_DISABLED = "1";
      NODE_ENV = "production";
    };

    buildPhase = ''
      runHook preBuild

      bun run build:database

      pushd packages/database
      bun build ./src/migrate-entrypoint.ts --compile --minify --outfile migrate-bin
      popd

      pushd apps/job-server
      bun build ./src/index.ts --compile --minify --outfile server
      popd

      pushd apps/nextjs-app
      bun --bun next build --experimental-build-mode compile
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      job_dir=$out/lib/streamystats/job-server
      web_dir=$out/lib/streamystats/web
      mkdir -p $out/bin $job_dir $web_dir/apps/nextjs-app/.next

      cp packages/database/migrate-bin $job_dir/
      cp -R packages/database/drizzle $job_dir/
      cp apps/job-server/server $job_dir/
      mkdir -p $job_dir/node_modules/.bun/geoip-lite@1.4.10/node_modules/geoip-lite
      geoip_data=$(find . -type d -path '*/geoip-lite/data' -print -quit)
      cp -R "$geoip_data" $job_dir/node_modules/.bun/geoip-lite@1.4.10/node_modules/geoip-lite/

      cp -R apps/nextjs-app/.next/standalone/. $web_dir/
      cp -R apps/nextjs-app/.next/static $web_dir/apps/nextjs-app/.next/
      cp -R apps/nextjs-app/public $web_dir/apps/nextjs-app/
      find $web_dir -type l -name '*linuxmusl*' -delete
      find $web_dir -type d -name '*linuxmusl*' -prune -exec rm -rf {} +

      makeWrapper $job_dir/migrate-bin $out/bin/streamystats-migrate \
        --chdir $job_dir
      makeWrapper $job_dir/server $out/bin/streamystats-job-server \
        --chdir $job_dir
      makeWrapper ${lib.getExe nodejs_22} $out/bin/streamystats-web \
        --chdir $web_dir/apps/nextjs-app \
        --add-flags server.js

      runHook postInstall
    '';

    meta = {
      description = "Jellyfin analytics and statistics platform";
      homepage = "https://github.com/fredrikburmester/streamystats";
      changelog = "https://github.com/fredrikburmester/streamystats/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  })
