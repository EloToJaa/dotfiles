{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-smart-filter";
  version = "unstable-2025-07-14";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "b8860253fc44e500edeb7a09db648a829084facd";
    hash = "sha256-29K8PmBoqAMcQhDIfOVnbJt2FU4BR6k23Es9CqyEloo=";
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
