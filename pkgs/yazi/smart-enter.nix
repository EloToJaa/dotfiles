{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-enter";
  version = "0-unstable-2026-10-14";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "6cf1f4389b4d56954260f713fa999067d0b2f20a";
    hash = "sha256-u6YGXBcwZUjsbIQjpkazS3j7t+Zm1JL1AONG3sbuUeM=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-enter.yazi/* $out
  '';

  meta = with lib; {
    description = "Open files or enter directories all in one key!";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
