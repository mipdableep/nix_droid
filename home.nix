{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./home/zsh.nix
  ];

  programs = {
    home-manager.enable = true;

    fzf.enable = true;
    fzf.enableZshIntegration = true;
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;

    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      flags = ["--disable-up-arrow"];
      settings = {
        style = "compact";
        inline_height = 22;
      };
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
  # Read the changelog before changing this value
  home.stateVersion = "24.05";

  # insert home-manager config
}
