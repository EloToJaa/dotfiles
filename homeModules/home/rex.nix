{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.modules.home.rex;
  # Upstream's preCheck runs clippy with -D warnings and src/platform/fs.rs trips
  # clippy::byte_char_slices; the skipped tests shell out to /bin/ps, which the
  # build sandbox lacks.
  rexRunePackage = inputs.rex-rune.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    preCheck = builtins.replaceStrings ["-- -D warnings"] ["-- -D warnings -A clippy::byte_char_slices"] old.preCheck;
    checkFlags =
      (old.checkFlags or [])
      ++ [
        "--skip=ssh::install::tests::stop_kills_group_and_drop_kills_without_waiting_for_a_question"
        "--skip=ssh::install::tests::stop_sweeps_a_term_ignoring_group_member_without_terminal_fds"
      ];
  });
in {
  options.modules.home.rex = {
    enable = mkEnableOption "Enable rex terminal multiplexer";
    server.enable = mkEnableOption "Run a personal rex server as a systemd user service";
    client.enable = mkEnableOption "Install the unofficial Rex Rune desktop client";
    config = mkOption {
      type = types.nullOr (types.either types.lines types.path);
      default = null;
      description = "Lua configuration written to ~/.config/rex/init.lua";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.rex = {
      enable = true;
      inherit (cfg) config;
      # the guard is added through home-manager's ~/.ssh/config, which is unmanaged here
      sshGuard = lib.mkDefault config.programs.ssh.enable;
    };
    services.rex.enable = cfg.server.enable;
    # The host enables lingering for this user (nixosModules/base/user.nix), so the
    # module's unconditional `loginctl enable-linger` warning does not apply.
    # This also drops any other home-manager warnings, because they cannot be filtered.
    warnings = lib.mkIf (cfg.server.enable && (osConfig.users.users.${config.home.username}.linger or false)) (lib.mkForce []);
    home.packages = lib.optionals cfg.client.enable [rexRunePackage];
  };
}
