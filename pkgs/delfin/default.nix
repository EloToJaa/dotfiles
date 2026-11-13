# Fisch's fork of Delfin; upstream (codeberg.org/avery42/delfin) is unmaintained.
{
  lib,
  stdenv,
  appstream,
  cargo,
  desktop-file-utils,
  fetchFromCodeberg,
  gtk4,
  libadwaita,
  libepoxy,
  libglvnd,
  meson,
  mpv,
  ninja,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "delfin";
  version = "0.4.8-unstable-2026-07-24";

  src = fetchFromCodeberg {
    owner = "Fisch";
    repo = "delfin";
    rev = "ca81d37496078e67b2f29c976e14b816ba3e211a";
    hash = "sha256-dOx3oYwxk70iesuxE8kCEoG+0NpZKRlkUyQwcQUThF4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-cab7KPywPj2sbHB7Ih9/SdMnOKBY9RMZdBMyJA8PTLU=";
  };

  # meson expects cargo output in target/<profile>, but CARGO_BUILD_TARGET adds the triple.
  # The vendored jellyfin_api crate (generated for Jellyfin 10.9) rejects unknown fields,
  # so newer servers sending e.g. `OriginalLanguage` crash Delfin; drop the strictness
  # and its file checksums. https://codeberg.org/avery42/delfin/issues/240
  postPatch = ''
    substituteInPlace delfin/meson.build --replace-fail \
      "'delfin' / rust_target / meson.project_name()" \
      "'delfin' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name()"

    crate=$(echo "$cargoDepsCopy"/*/jellyfin_api-*)
    sed -i '/#\[serde(deny_unknown_fields)\]/d' "$crate/src/lib.rs"
    sed -i 's/"files":{[^}]*}/"files":{}/' "$crate/.cargo-checksum.json"
  '';

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    libglvnd
    libepoxy
    mpv
    openssl
  ];

  mesonFlags = [
    (lib.mesonOption "profile" "release")
  ];

  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

  meta = {
    description = "Stream movies and TV shows from Jellyfin";
    homepage = "https://codeberg.org/Fisch/delfin";
    license = lib.licenses.gpl3Only;
    mainProgram = "delfin";
    platforms = lib.platforms.linux;
  };
})
