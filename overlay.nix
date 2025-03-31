inputs: final: prev: {
  rpi5-atf = final.arm-trusted-firmware.buildArmTrustedFirmware {
    platform = "rpi5";
    extraMakeFlags = [
      "PRELOADED_BL33_BASE=0x20000"
      "RPI3_PRELOADED_DTB_BASE=0x1F0000"
      "SUPPORT_VFP=1"
      "SMC_PCI_SUPPORT=1"
    ];
    filesToInstall = [ "build/rpi5/release/bl31.bin" ];
    nativeBuildInputs = [ ];
  };
  inherit (inputs) rpi5-edk2-platforms edk2-non-osi;
  rpi5-uefi = final.callPackage ./package.nix { };
  boot_folder = final.callPackage ./boot_folder.nix { };
}
