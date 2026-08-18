{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  fetchurl,
  home-assistant,
  lib,
}: let
  mini-racer = home-assistant.python3Packages.buildPythonPackage {
    pname = "mini-racer";
    version = "0.14.1";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/c2/3c/c5bd479784826bbbc69f713aae2bcfd5ef353ba4e5e0e661666938474535/mini_racer-0.14.1-py3-none-manylinux_2_27_x86_64.whl";
      hash = "sha256-zfOgiOE2PxamlSiPiCq/drNwW44d8hQYIIuH7QEAN6Q=";
    };
    meta = {
      homepage = "https://github.com/bpcreech/PyMiniRacer";
      license = lib.licenses.isc;
    };
  };
in
  buildHomeAssistantComponent (finalAttrs: {
    owner = "Tasshack";
    domain = "dreame_vacuum";
    version = "2.0.0b25";

    src = fetchFromGitHub {
      owner = finalAttrs.owner;
      repo = "dreame-vacuum";
      tag = "v${finalAttrs.version}";
      hash = "sha256-eZcv3Xwywt4UDxEU1aP60+KtOj1xibPPahFim2U5gaA=";
    };

    dependencies =
      [
        mini-racer
      ]
      ++ (with home-assistant.python3Packages; [
        numpy
        paho-mqtt
        pillow
        pybase64
        pycryptodome
        python-miio
        requests
      ]);

    meta = {
      description = "Home Assistant integration for Dreame robot vacuums";
      homepage = "https://github.com/Tasshack/dreame-vacuum";
      license = lib.licenses.mit;
    };
  })
