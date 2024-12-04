{
  config,
  pkgs,
  username,
  nix-index-database,
  ...
}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";
    history.size = 10000;
    history.save = 10000;
    history.expireDuplicatesFirst = true;
    history.ignoreDups = true;
    history.ignoreSpace = true;
    historySubstringSearch.enable = true;

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];

    shellAliases = {
      cd = "z";
      nix_gc = "nix-collect-garbage --delete-old";
      runzsh = "source $HOME/.zshrc";
      show_path = "echo $PATH | tr ':' '\n'";

      fmanix = "manix \"\" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview=\"manix '{}'\" | xargs manix";
      cat = "bat";

      ls = "lsd";
      lss = "lsd";
      la = "lsd -lA --date relative";
      lt = "lsd --tree";
      ltd = "lsd --tree --depth";
    };

    envExtra = ''
      export PATH=$PATH:$HOME/.local/bin
      export PATH=$PATH:$HOME/.cargo/bin
    '';
      #export PATH=$PATH:$HOME/.local/share/bob/nvim-bin

    initExtra = ''
      bindkey '^e' end-of-line
      bindkey ";5C" forward-word
      bindkey ";5D" backward-word

      zstyle ':completion:*:*:*:*:*' menu select

      # Complete . and .. special directories
      zstyle ':completion:*' special-dirs true

      zstyle ':completion:*' list-colors ""
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

      # disable named-directories autocompletion
      zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

      # Use caching so that commands like apt and dpkg complete are useable
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

      # Don't complete uninteresting users
      zstyle ':completion:*:*:*:users' ignored-patterns \
              adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
              clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
              gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
              ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
              named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
              operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
              rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
              usbmux uucp vcsa wwwrun xfs '_*'
      # ... unless we really want to.
      zstyle '*' single-ignored complete

      # https://thevaluable.dev/zsh-completion-guide-examples/
      zstyle ':completion:*' completer _extensions _complete _approximate
      zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
      zstyle ':completion:*' squeeze-slashes true
      zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'


      # Function to rebuild NixOS configuration and commit changes if needed
      Nix_rebuild() {
          # Description: rebuild the OS and commit if needed

          # Count the number of arguments passed to the function
          local argc=$#argv

          # Determine the host based on the number of arguments
          if [[ $argc -ne 1 ]]; then
              # If no argument is provided, use smenu to select the host interactively
              HOST=$(echo "wsl vm" | smenu -t1)
          else
              # Otherwise, use the provided argument as the host
              HOST=$1
          fi

          # Change directory to the Nix configuration directory
          pushd ~/Nix-conf > /dev/null

          # Check if there are any changes in the .nix files
          if git diff --quiet ./**/*.nix; then
              echo "No changes detected, exiting."
              # Return to the previous directory and exit the function
              popd > /dev/null
              return
          fi

          # Run alejandra to format .nix files (if alejandra is a command-line tool for formatting)
          alejandra -q . > /dev/null

          # Show the differences in .nix files with zero context lines
          git diff -U0 ./**/*.nix

          # Stage all changes for commit
          git add .

          # Rebuild the NixOS configuration and switch to the new generation
          if sudo nixos-rebuild --flake .#$HOST switch; then
              # Get the current generation of the NixOS system
              GEN=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep "current" | sed 's/  (current)//')
              echo $GEN

              # Commit the changes with the generation number as the message
              git commit -m "$GEN"

              # Return to the previous directory
              popd > /dev/null
          else
              # If the rebuild failed, print an error message
              echo "nixos-rebuild failed, exiting."

              # Reset any changes to .nix files
              git reset ./**/*.nix

              # Return to the previous directory and exit with status 1
              popd > /dev/null
              return 1
          fi
      }
    '';
  };
}
