{
  fetchurl,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stack-in-card";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/custom-cards/stack-in-card/releases/download/${finalAttrs.version}/stack-in-card.js";
    hash = "sha256-PrPIkJByd8XknwlR//eHr3APBMMxW+TA162Ujk7wEb0=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 $src $out/stack-in-card.js

    runHook postInstall
  '';

  passthru.entrypoint = "stack-in-card.js";

  meta = {
    description = "Group multiple Home Assistant cards without borders";
    homepage = "https://github.com/custom-cards/stack-in-card";
    license = lib.licenses.mit;
  };
})
