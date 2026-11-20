{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  lib,
  home-assistant,
}:
buildHomeAssistantComponent (finalAttrs: {
  owner = "thedeemling";
  domain = "energa_my_meter";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = finalAttrs.owner;
    repo = "hass-energa-my-meter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R1kPebZRMQGKhgCDbk4XKMyO5kZxgsi+SsU7w3q111g=";
  };

  dependencies = with home-assistant.python3Packages; [
    lxml
    mechanize
  ];

  meta = {
    description = "Home Assistant integration for Energa My Meter";
    homepage = "https://github.com/thedeemling/hass-energa-my-meter";
    license = lib.licenses.mit;
  };
})
