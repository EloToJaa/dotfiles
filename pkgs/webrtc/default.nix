{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  go2rtc,
  lib,
}:
buildHomeAssistantComponent (finalAttrs: {
  owner = "AlexxIT";
  domain = "webrtc";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = finalAttrs.owner;
    repo = "WebRTC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Rw95G7Ro0QvKZ7SNMIA/Q8Kr56QQqxos+t1xksuDJ0=";
  };

  postPatch = ''
    substituteInPlace custom_components/webrtc/utils.py \
      --replace-fail \
        "def validate_binary(hass: HomeAssistant) -> Optional[str]:" \
        $'def validate_binary(hass: HomeAssistant) -> Optional[str]:\n    return "${lib.getExe go2rtc}"'
  '';

  meta = {
    description = "Home Assistant WebRTC camera integration";
    homepage = "https://github.com/AlexxIT/WebRTC";
    license = lib.licenses.mit;
  };
})
