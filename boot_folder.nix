{ rpi5-uefi, runCommand }:

runCommand "boot_folder" { } ''
  mkdir $out
  cd $out
  cp ${./config.txt} config.txt
  cp ${rpi5-uefi.fd}/FV/RPI_EFI.fd RPI_EFI.fd
''
