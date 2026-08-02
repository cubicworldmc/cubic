# Everything has the same public key and the private key is 'public'.
let
  key = builtins.readFile ../../test/id_ed25519.pub;
in
(import ../secrets.nix).secretsAttrSet {
  cubic = key;
}
