{
  description = "yxeng nix-darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
          ];

          homebrew = {
            enable = true;
            onActivation.autoUpdate = false;
            onActivation.cleanup = "uninstall";

            taps = [ "d12frosted/emacs-plus" ];
            brews = [
              "d12frosted/emacs-plus/emacs-plus@29"
            ];

            casks = [
              "kitty"
              "raycast"
              "unnaturalscrollwheels"
            ];
          };

          system.defaults.CustomUserPreferences = {
            "com.apple.dock" = {
              "expose-group-apps" = true;
            };

            "com.apple.spaces" = {
              "spans-displays" = true;
            };

            "NSGlobalDomain" = {
              "NSWindowShouldDragOnGesture" = true;
            };
          };

          users.users.yingxuan = {
            name = "yingxuan";
            home = "/Users/yingxuan";
          };

          nix.settings.trusted-users = [ "yingxuan" ];

          nix.gc = {
            automatic = true;
          };

          # use touch id for sudo
          security.pam.enableSudoTouchIdAuth = true;

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
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
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#yxeng-macbook
      darwinConfigurations."yxeng-macbook" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
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

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."yxeng-macbook".pkgs;
    };
}
