{ lib, ... }:

{
  environment.etc."auto_master" = {
    # Allow nix-darwin to adopt the existing stock macOS map.
    knownSha256Hashes = [ "b2aac03248e8f229c703561f5bb059f9be491e5db9f447692398d775a9fb12a5" ];
    text = ''
      +auto_master
      /home auto_home -nobrowse,hidefromfinder
      /Network/Servers -fstab
      /- -static
      /Users/Shared/lab-nfs /etc/auto_lab
    '';
  };

  environment.etc."auto_lab".text = ''
    files -fstype=nfs,vers=4,tcp,resvport,hard,nosuid,rsize=1048576,wsize=1048576,dsize=262144,rdirplus truenas:/mnt/tank/files
  '';

  home-manager.users.yingxuan = { config, ... }: {
    home.file."nas".source = config.lib.file.mkOutOfStoreSymlink "/Users/Shared/lab-nfs/files";
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    /bin/mkdir -p /Users/Shared/lab-nfs
    /usr/sbin/automount -vc
  '';
}
