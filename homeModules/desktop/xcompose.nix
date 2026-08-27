{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop;
in {
  config = lib.mkIf cfg.enable {
    # Keep the table at the conventional path for X11 and point native
    # Wayland toolkits at it explicitly.
    home.file.".XCompose".text = ''
      # Preserve the locale's standard Compose table (including accents).
      include "%L"

      # Typography and symbols.
      <Multi_key> <space> <space>       : "—"   # em dash
      <Multi_key> <minus> <minus>       : "–"   # en dash
      <Multi_key> <period> <period> <period> : "…"
      <Multi_key> <less> <less>         : "«"
      <Multi_key> <greater> <greater>   : "»"
      <Multi_key> <exclam> <exclam>     : "¡"
      <Multi_key> <question> <question> : "¿"
      <Multi_key> <minus> <greater>     : "→"
      <Multi_key> <less> <minus>        : "←"
      <Multi_key> <equal> <greater>     : "⇒"
      <Multi_key> <less> <equal>        : "≤"
      <Multi_key> <greater> <equal>     : "≥"
      <Multi_key> <slash> <equal>       : "≠"
      <Multi_key> <c> <o>               : "©"
      <Multi_key> <r> <o>               : "®"
      <Multi_key> <t> <m>               : "™"

      # Omarchy-style mnemonic emoji: Compose, m, mnemonic.
      <Multi_key> <m> <h> : "❤️"  # heart
      <Multi_key> <m> <s> : "😄"  # smile
      <Multi_key> <m> <c> : "😂"  # cry/laugh
      <Multi_key> <m> <y> : "👍"  # yes/approval
      <Multi_key> <m> <n> : "👎"  # no/disapproval
      <Multi_key> <m> <x> : "🎉"  # celebration
      <Multi_key> <m> <g> : "👋"  # greeting
      <Multi_key> <m> <v> : "✌️"  # victory
      <Multi_key> <m> <o> : "👌"  # OK
      <Multi_key> <m> <p> : "🙏"  # please/thanks
      <Multi_key> <m> <i> : "😉"  # wink
      <Multi_key> <m> <k> : "😘"  # kiss
      <Multi_key> <m> <a> : "💪"  # strength
      <Multi_key> <m> <t> : "🥂"  # toast
      <Multi_key> <m> <1> : "💯"  # 100%
    '';

    home.packages = [pkgs.noto-fonts-color-emoji];
    home.sessionVariables = {
      XCOMPOSEFILE = "$HOME/.XCompose";
      EMOJI_FONT = "Noto Color Emoji";
    };
  };
}
