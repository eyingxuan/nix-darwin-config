{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "yingxuan";
  home.homeDirectory = "/Users/yingxuan";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # CR-someday yieng: all this seems oddly specific to mac, and so it
    # shouldn't belong in home manager
    git = {
      enable = true;
      userName = "Ying Xuan Eng";
      userEmail = "engyingxuan@gmail.com";
      signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILahCDtkc84c6FuYxWBCE05O3stfRJIbm0yFh6ZlWIjq";
      ignores = [ ".DS_Store"];
      extraConfig = {
        gpg.format = "ssh";
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        commit.gpgsign = true;
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      shellAliases = {
        switch = "darwin-rebuild switch --flake ~/.config/nix-darwin";
        ec = "emacsclient -a '' -c -t";
      };
    };

    ssh = {
      enable = true;
      extraConfig = ''
          Host *
          IdentityAgent ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    '';
    };

  };
}
