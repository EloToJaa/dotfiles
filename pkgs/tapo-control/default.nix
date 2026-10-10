{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  lib,
}:
buildHomeAssistantComponent (finalAttrs: {
  owner = "JurajNyiri";
  domain = "tapo_control";
  version = "7.1.25";

  src = fetchFromGitHub {
    owner = finalAttrs.owner;
    repo = "HomeAssistant-Tapo-Control";
    tag = finalAttrs.version;
    hash = "sha256-1FNFdtoXyrZ6ng06LiODsxMfP4MtpqiSJofTekq0TUE=";
  };

  # Home Assistant's package set carries its own pytapo, so point the component
  # at that version in two places: manifestCheckPhase rejects a manifest
  # requirement it cannot satisfy, and async_setup_entry raises DependencyError
  # unless PYTAPO_REQUIRED_VERSION equals the installed version exactly. Both
  # are matched by pattern rather than by literal, because upstream bumps the
  # pin most releases and naming the old version made each one fail to build.
  #
  # Refuse to rewrite the pin backwards. The component imports modules that
  # only exist in later pytapo releases (media_stream.snapshot arrived in
  # 3.4.20), so loosening the pin onto an older pytapo than upstream asks for
  # builds cleanly and then fails at import time inside Home Assistant. Failing
  # here keeps that breakage out of an automated update.
  postPatch = ''
    have=${home-assistant.python3Packages.pytapo.version}
    required=$(grep -oE 'pytapo==[0-9]+(\.[0-9]+)*' custom_components/tapo_control/manifest.json | head -1 | cut -d= -f3)

    if [ -z "$required" ]; then
      echo "tapo_control manifest no longer pins pytapo with '==': revisit this patch" >&2
      exit 1
    fi
    if [ "$required" != "$have" ] && [ "$(printf '%s\n%s\n' "$required" "$have" | sort -V | tail -1)" = "$required" ]; then
      echo "tapo_control $version needs pytapo $required but nixpkgs provides $have:" >&2
      echo "hold this package back until nixpkgs ships pytapo $required or newer" >&2
      exit 1
    fi

    sed -i -E "s|pytapo==[0-9]+(\.[0-9]+)*|pytapo==$have|" \
      custom_components/tapo_control/manifest.json
    sed -i -E "s|PYTAPO_REQUIRED_VERSION = .*|PYTAPO_REQUIRED_VERSION = \"$have\"|" \
      custom_components/tapo_control/const.py
  '';

  dependencies = with home-assistant.python3Packages;
    [
      pytapo
      python-kasa
    ]
    ++ python-kasa.optional-dependencies.speedups;

  meta = {
    description = "Home Assistant integration for controlling Tapo cameras";
    homepage = "https://github.com/JurajNyiri/HomeAssistant-Tapo-Control";
    license = lib.licenses.asl20;
  };
})
