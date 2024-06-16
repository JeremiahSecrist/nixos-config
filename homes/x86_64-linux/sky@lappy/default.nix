{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  home
, # The home architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this home (eg. `x86_64-home`).
  format
, # A normalized name for the home target (eg. `home`).
  virtual
, # A boolean to determine whether this home is a virtual target using nixos-generators.
  host
, # The host name for this home.

  # All other arguments come from the home home.
  config
, ...
}:
with lib.internal;
let
  pubkey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBA9i9HoP7X8Ufzz8rAaP7Nl3UOMZxQHMrsnA5aEQfpTyIQ1qW68jJ4jGK5V6Wv27MMc3czDU1qfFWIbGEWurUHQ=";
  myPubKeyFile = "${pkgs.writeText "mykey.pub" "${pubkey}\n"}";
in
{
  # Your configuration.
  snowfallorg.user.enable = true;

  home = {
    stateVersion = "24.05";
    file = {
      wallpapers = {
        recursive = true;
        source = ./files/wallpapers;
        target = "./Pictures/wallpapers";
      };
    };
    sessionVariables = {
      EDITOR = "hx";
      DIRENV_LOG_FORMAT = "";
    };
    packages = with pkgs; [
      bambu-studio
      internal.tabby
      patch-discord
      vesktop
      oterm
      nil
      nixd
      xdg-utils
      blender
      element-desktop
      mplayer
      warp
      prismlauncher
      btop
      git
      gnupg
      tldr
      nixfmt
      protonvpn-cli
      yubikey-personalization-gui
      yubioath-flutter
      protonvpn-gui
    ];
  };
  services.gpg-agent = {
    # enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableZshIntegration = true;
    enableScDaemon = true;
    sshKeys = [ "8D53CA91572B3252096210F0A5D58142765E3114" ];
    # pinentryFlavor = "gnome3";
    # defaultCacheTtl = 345600;
    # defaultCacheTtlSsh = 345600;
    # maxCacheTtl = 345600;
    # maxCacheTtlSsh = 345600;
    # extraConfig = "disable-ccid\n";
  };
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
        charset = "utf-8";
      };
      "*.lock" = {
        indent_size = "unset";
      };
      "*.{json,lock,md,nix,pl,pm,py,rb,sh,xml}" = {
        indent_style = "space";
      };
      "*.gpg" = {
        indent_size = "unset";
        insert_final_newline = "unset";
      };
    };
  };
  xdg = {
    enable = true;
    mime.enable = true;
  };

  programs = {
    vscode.enable = true;
    helix.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enableZshIntegration = true;
      enable = true;
    };
    chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        { id = "lgjhepbpjcmfmjlpkkdjlbgomamkgonb"; }
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
      ];
    };
    git = {
      enable = true;
      userName = "Jermeiah S";
      userEmail = "owner@arouzing.xyz";
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        user.signingkey = myPubKeyFile;
      };
      diff-so-fancy.enable = true;
      lfs.enable = true;
    };
    ssh = {
      enable = true;
      compression = true;
      forwardAgent = true;
      extraConfig = "PKCS11Provider ${pkgs.tpm2-pkcs11}/lib/libtpm2_pkcs11.so\n";
      matchBlocks = {
        "107.172.92.84" = {
          host = "107.172.92.84";
          forwardAgent = true;
          # extraOptions = {
          #   AddKeysToAgent = "yes";
          #   # RemoteForward = "/run/user/1000/gnupg/ /run/user/1000/gnupg/";
          # };
        };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          forwardAgent = false;
        };
        "*.tail3f4f1.ts.net" = {
          user = "ops";
        };
      };
    };
    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      history = {
        share = true;
        path = "$ZDOTDIR/.zsh_history";
        save = 10000000;
      };

      initExtra = ''
        function set_win_title(){
            echo -ne "\033]0; $(basename "$PWD") \007"
        }
        bindkey "^[[3~" delete-char
        bindkey "^H" backward-kill-word
        bindkey '^[[3;6~' kill-word
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        # eval "$(zellij setup --generate-auto-start zsh)"
        # export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
      '';
      envExtra = ''
        starship_precmd_user_func="set_win_title"
        precmd_functions+=(set_win_title)
      '';
      localVariables = {
        #   EDITOR = "hx";
        TERM = "kitty";
      };
      shellAliases = {
        reagent = "gpg-connect-agent reloadagent /bye";
        fucking = "sudo";
        tssh = "ssh-add -s ${pkgs.tpm2-pkcs11}/lib/libtpm2_pkcs11.so";
        tpm2-tool = "${pkgs.opensc}/bin/pkcs11-tool --module ${pkgs.tpm2-pkcs11}/lib/libtpm2_pkcs11.so";
        inst = "nix profile install";
      };
      enableCompletion = true;
      completionInit = ''
        compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION" && autoload -U compinit && zstyle ':completion:*' menu select && zmodload zsh/complist && compinit && _comp_options+=(globdots)
      '';
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.internal.zsh-nix-shell;
        }
      ];
    };
  };
}
