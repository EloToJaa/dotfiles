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
