(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    root = lock.nodes.${lock.root};
    flake-compat = lock.nodes.${root.inputs.flake-compat}.locked;
  in
  fetchTarball {
    url = with flake-compat; "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    sha256 = flake-compat.narHash;
  }
) { src = ./.; }).defaultNix
