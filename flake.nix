{
  description = "yxeng nix-darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/8809585e6937d0b07fc066792c8c9abf9c3fe5c4";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            ispell
            nixfmt-rfc-style
            ripgrep
            aerospace
            wabt
            go-grip
          ];

          homebrew = {
            enable = true;
            enableZshIntegration = true;

            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
            onActivation.cleanup = "uninstall";

            taps = [
              {
                name = "d12frosted/emacs-plus";
                trusted = true;
              }
              {
                name = "withgraphite/tap";
                trusted = true;
              }
            ];

            brews = [
              "withgraphite/tap/graphite"
              "pi-coding-agent"
              "iperf3"
              "fio"
            ];

            casks = [
              "1password-cli"
              "chatgpt" # Codex desktop (replaces the deprecated codex-app cask).
              "claude-code"
              "codex"
              "tailscale-app"
              "legcord"
              "d12frosted/emacs-plus/emacs-plus-app"
              "kitty"
              "appcleaner"
              "spotify"
              "istat-menus@6"
            ];
          };

          # Match the saved Dock preferences; leave unspecified macOS defaults alone.
          system.defaults.dock = {
            tilesize = 33;
            show-recents = false;
            expose-group-apps = true;
            showAppExposeGestureEnabled = true;

            persistent-apps = [
              # Use the app directly; /Applications/Safari.app is a symlink with a shortcut badge.
              "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
              "/System/Applications/Messages.app"
              "/System/Applications/Reminders.app"
              "/System/Applications/Notes.app"
              "/System/Applications/System Settings.app"
              "/System/Applications/Music.app"
              "/Applications/kitty.app"
              "/Applications/Rex Beta.app"
            ];

            persistent-others = [
              {
                folder = {
                  path = "/Users/yingxuan/Downloads";
                  arrangement = "date-added";
                  displayas = "stack";
                  showas = "automatic";
                };
              }
            ];

            wvous-tl-corner = 13; # Lock Screen (with Command held; see modifier below).
            wvous-br-corner = 1; # Disabled.
          };

          system.defaults.CustomUserPreferences = {
            "com.apple.dock" = {
              # Hot corner modifiers have no typed nix-darwin option.
              "wvous-tl-modifier" = 1048576; # Command.
              "wvous-br-modifier" = 0;
            };

            "com.apple.spaces" = {
              "spans-displays" = true;
            };

            "NSGlobalDomain" = {
              "NSWindowShouldDragOnGesture" = true;
            };
          };

          system.primaryUser = "yingxuan";

          users.users.yingxuan = {
            name = "yingxuan";
            home = "/Users/yingxuan";
          };

          nix.settings.trusted-users = [ "yingxuan" ];

          nix.gc = {
            automatic = true;
          };

          # use touch id for sudo
          # security.pam.enableSudoTouchIdAuth = true;
          security.pam.services.sudo_local.touchIdAuth = true;

          # Auto upgrade nix package and the daemon service.
          # services.nix-daemon.enable = true;
          # nix.package = pkgs.nix;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
      mkHost =
        hostConfiguration:
        nix-darwin.lib.darwinSystem {
          modules = [
            configuration
            hostConfiguration
            ./nfs.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.yingxuan = import ./home-manager.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
    in
    {
      # Without a #host suffix, darwin-rebuild uses scutil --get LocalHostName.
      # $ darwin-rebuild build --flake .
      darwinConfigurations = {
        "yxeng-macbook" = mkHost { };
        "yxeng-mac-studio" = mkHost {
          homebrew.brews = [
            "youssofal/mtplx/mtplx"
          ];
          homebrew.casks = [
            "freefilesync"
              "monitorcontrol"
          ];
        };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."yxeng-macbook".pkgs;
    };
}
