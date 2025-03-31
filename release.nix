{
  nixpkgs ? builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz",
}:

{
  locked = (import ./.).hydraJobs;
  updated = ((import ./.).overrideInputs { inherit nixpkgs; }).hydraJobs;
}
