{
  stdenv,
  lib,
  edk2,
  util-linux,
  nasm,
  acpica-tools,
  llvmPackages,
  csmSupport ? false,
  seabios ? null,
  fdSize2MB ? csmSupport,
  fdSize4MB ? false,
  secureBoot ? true,
  httpSupport ? true,
  tpmSupport ? true,
  tlsSupport ? true,
  debug ? false,
  sourceDebug ? debug,
  rpi5-edk2-platforms,
  edk2-non-osi,
  rpi5-atf,
}:

assert csmSupport -> seabios != null;

let

  projectDscPath = "edk2-platforms/Platform/RaspberryPi/RPi5/RPi5.dsc";

  version = lib.getVersion edk2;

in

edk2.mkDerivation projectDscPath (finalAttrs: {
  pname = "RPI_EFI";
  inherit version;

  # src = "${rpi5-uefi}/edk2";

  outputs = [
    "out"
    "fd"
  ];

  nativeBuildInputs =
    [
      util-linux
      nasm
      acpica-tools
    ]
    ++ lib.optionals stdenv.cc.isClang [
      llvmPackages.bintools
      llvmPackages.llvm
    ];
  strictDeps = true;

  hardeningDisable = [
    "format"
    "stackprotector"
    "pic"
    "fortify"
  ];

  buildFlags =
    # IPv6 has no reason to be disabled.
    [
      "-D NETWORK_IP6_ENABLE=TRUE"
      "-D TFA_BUILD_ARTIFACTS=${rpi5-atf}"
    ]
    ++ lib.optionals debug [ "-D DEBUG_ON_SERIAL_PORT=TRUE" ]
    ++ lib.optionals sourceDebug [ "-D SOURCE_DEBUG_ENABLE=TRUE" ]
    ++ lib.optionals secureBoot [ "-D SECURE_BOOT_ENABLE=TRUE" ]
    ++ lib.optionals csmSupport [ "-D CSM_ENABLE" ]
    ++ lib.optionals fdSize2MB [ "-D FD_SIZE_2MB" ]
    ++ lib.optionals fdSize4MB [ "-D FD_SIZE_4MB" ]
    ++ lib.optionals httpSupport [
      "-D NETWORK_HTTP_ENABLE=TRUE"
      "-D NETWORK_HTTP_BOOT_ENABLE=TRUE"
    ]
    ++ lib.optionals tlsSupport [ "-D NETWORK_TLS_ENABLE=TRUE" ]
    ++ lib.optionals tpmSupport [
      "-D TPM_ENABLE"
      "-D TPM2_ENABLE"
      "-D TPM2_CONFIG_ENABLE"
    ];

  buildConfig = if debug then "DEBUG" else "RELEASE";
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Qunused-arguments";

  env.PYTHON_COMMAND = "python3";

  patches = [ ./0001-MdeModulePkg-SdMmcPciHcDxe-Support-override-for-SD-1.patch ];
  postPatch =
    ''
      cp -r --no-preserve=all ${rpi5-edk2-platforms} ./edk2-platforms
      cp -r --no-preserve=all ${edk2-non-osi} ./edk2-non-osi
      export PACKAGES_PATH=$PWD:$PWD/edk2-platforms:$PWD/edk2-non-osi
    ''
    + lib.optionalString csmSupport ''
      cp ${seabios}/Csm16.bin OvmfPkg/Csm/Csm16/Csm16.bin
    '';

  postFixup = ''
    mkdir -vp $fd/FV
    mv -v $out/FV/RPI_EFI.fd $fd/FV
  '';

  dontPatchELF = true;

  meta = {
    description = "Sample UEFI firmware for RPi5";
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.aarch64;
    maintainers = with lib.maintainers; [ elvishjerricco ];
  };
})
