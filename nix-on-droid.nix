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

    #languages
    go
    rustup
    gcc
    gnumake
    cmake
    python313
    nodejs_22 #for nvim

    # tools
    mariadb
    just
    tmux
    openssh
    git
    zsh

    # cli tools
    neovim
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
