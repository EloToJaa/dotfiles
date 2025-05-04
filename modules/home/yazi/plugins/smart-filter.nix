{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-filter";
  version = "unstable-2025-05-04";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "864a0210d9ba1e8eb925160c2e2a25342031d8d3";
    hash = "sha256-m3709h7/AHJAtoJ3ebDA40c77D+5dCycpecprjVqj/k=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/smart-filter.yazi/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin that makes filters smarter: continuous filtering, automatically enter unique directory, open file on submitting.";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
