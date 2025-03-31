{
  inputs = {
    flake-compat.url = "github:ElvishJerricco/flake-compat/add-overrideInputs";
    flake-compat.flake = false;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rpi5-edk2-platforms.url = "github:ElvishJerricco/edk2-platforms/rpi5-dev";
    rpi5-edk2-platforms.flake = false;
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
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
        default = self.legacyPackages.${system}.pkgsCross.aarch64-multiplatform.rpi5-uefi.fd;
        rpi5-uefi = self.legacyPackages.${system}.pkgsCross.aarch64-multiplatform.rpi5-uefi;
        boot_folder = self.legacyPackages.${system}.pkgsCross.aarch64-multiplatform.boot_folder;
      });
      legacyPackages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "RPI_EFI";
        }
      );
      hydraJobs = self.packages.x86_64-linux;
    };
}
