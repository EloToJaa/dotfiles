{pkgs, ...}: {
  services.redis.package = pkgs.unstable.redis;
}
