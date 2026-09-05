{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "webrtc-camera";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "AlexxIT";
    repo = "WebRTC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Rw95G7Ro0QvKZ7SNMIA/Q8Kr56QQqxos+t1xksuDJ0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -v custom_components/webrtc/www/{digital-ptz.js,video-rtc.js,webrtc-camera.js} $out/

    runHook postInstall
  '';

  passthru.entrypoint = "webrtc-camera.js";

  meta = {
    description = "WebRTC camera card for Home Assistant";
    homepage = "https://github.com/AlexxIT/WebRTC";
    license = lib.licenses.mit;
  };
})
