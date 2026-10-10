{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  lib,
  home-assistant,
}:
buildHomeAssistantComponent (finalAttrs: {
  owner = "thedeemling";
  domain = "energa_my_meter";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = finalAttrs.owner;
    repo = "hass-energa-my-meter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wn1rNDcj5/0N2JXJ+oATRgQuojbsEXz8u0mAxo+Rz9M=";
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
