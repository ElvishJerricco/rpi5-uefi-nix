{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rpi5-edk2-platforms.url = "github:ElvishJerricco/edk2-platforms/rpi5-dev";
    rpi5-edk2-platforms.flake = false;
    atf-rpi5.url = "github:ARM-software/arm-trusted-firmware/v2.12.0";
    atf-rpi5.flake = false;
    edk2-non-osi.url = "github:tianocore/edk2-non-osi";
    edk2-non-osi.flake = false;
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }@inputs:
    {
      overlays.default = import ./overlay.nix inputs;
      legacyPackages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ (import ./overlay.nix inputs) ];
          config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "RPI_EFI";
        }
      );
    };
}
