{
  stdenv,
  agenix,
  jq,
  nix,
  replaceVars,
  ...
}:
stdenv.mkDerivation {
  pname = "cu_update_secrets";
  version = "0.1.0";
  src = replaceVars ./update_secrets.sh {
    jqBin = "${jq}/bin/jq";
    nixInstantiate = "${nix}/bin/nix-instantiate";
    agenix = "${agenix}/bin/agenix";
  };
  dontUnpack = true;
  installPhase = ''
    install -D $src $out/bin/cu_update_secrets
  '';
  meta.description = "updates test secrets based on values.nix";
}
