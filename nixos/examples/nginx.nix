rec {
  nginx-module = { config, ... }: {
    imports = [
      <nixpkgs/nixos/modules/services/web-servers/nginx>
    ];
    config.services.nginx.enable = true;
  };

  # <microgram/nixos> is a thin wrapper around <nixpkgs/nixos>
  nixos = import <microgram/nixos> { configuration = nginx-module; };

  ami = import <microgram/nixos/backends/ami.nix> {
    modules = [ nginx-module ];
    upload-context = rec {
      region = "ap-southeast-1";
      bucket = "platform-${region}";
    };
  };

  vm = import <microgram/nixos/backends/vm.nix> {
    modules = [ nginx-module ];
    fileName = "nginx.ova";
    vmName = "Nginx on Microgram";
  };
}
