{
  config,
  lib,
  pkgs,
  ...
}: {
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim

    # lsp
    nixd
    deadnix
    alejandra
    statix

    # tools
    go
    rustup
    mariadb
    just
    tmux
    openssh
    git

    # cli tools
    fd
    zoxide
    fzf
    bat
    tldr
    manix
    atuin
    hyperfine
    nix-search-cli
    ripgrep
    lsd
    cargo-binstall
    unzip #for nvim
    wget
    curl

    # cli programs
    btop
    gdu
    lazygit
    mycli # mysql
    litecli # sqlite
    yazi
  ];

  programs.zsh.enable = true;
  environment.pathsToLink = ["/usr/bin/zsh"];
  environment.shells = [pkgs.zsh];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };

  system.stateVersion = "24.05";
}
