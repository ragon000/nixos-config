{ config, lib, pkgs, inputs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.cli;
  ragon = config.ragon;
in
{
  options.ragon.cli.enable = lib.mkEnableOption "Enables ragons CLI stuff";
  options.ragon.cli.maximal = mkBoolOpt true;
  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = mkDefault true;
      enableSSHSupport = true;
    };
    ragon.nvim.enable = mkDefault true;

    services.lorri.enable = mkDefault cfg.maximal;
    ragon.user.persistent.extraDirectories = optionals cfg.maximal [
      ".local/share/direnv" # lorri
    ];

    security.sudo.extraConfig = "Defaults lecture = never";

    # root shell
    users.extraUsers.root.shell = pkgs.zsh;

    environment.shellAliases = {
      v = "nvim";
      vim = "nvim";
      gpl = "git pull";
      gp = "git push";
      gc = "git commit -v";
      kb = "git commit -m \"\$(curl -s http://whatthecommit.com/index.txt)\"";
      gs = "git status -v";
      gfc = "git fetch && git checkout";
      gl = "git log --graph";
      l = "exa -la --git";
      la = "exa -la --git";
      ls = "exa";
      ll = "exa -l --git";
      cat = "bat";
    };
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    environment.systemPackages = with pkgs; [
      nnn
      bat
      htop
      exa
      curl
      fd
      file
      fzf
      git
      neofetch
      ripgrep
    ] ++ optionals cfg.maximal [
      direnv # needed for lorri
      unzip
      my.pridecat
      pv
      killall
      pciutils
      youtube-dl
      aria2
      tmux
      libqalculate

    ];

  };

}
