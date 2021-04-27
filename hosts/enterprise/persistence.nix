{ ... }:

{

  ragon.user.persistent = {
    extraFiles = [
    ];
    extraDirectories = [
      ".config/zsh"
      ".android"
      "Android"
      ".cache/flutter" # so that flutter get all does not need to ALWAYS be run
      ".pub-cache" # so that flutter get all does not need to ALWAYS be run
      ".config/coc"
      ".config/pipewire/media-session.d"
      ".config/discordcanary"
      ".config/discord"
      ".config/Bitwarden"
      ".config/libreoffice"
      ".config/Timeular"
      ".config/Signal"
      ".config/spotify"
      ".config/obs-studio"
      ".config/TabNine"
      ".local/share/nvim"
      ".local/share/direnv" # lorri
      ".local/share/TabNine"
      ".mozilla/"
      ".thunderbird/" # Because of cause this isn't in .mozilla
      ".ssh"
      ".gnupg"
      "Downloads"
      "Backgrounds"
      "proj"
      "git"
    ];
  };
}
