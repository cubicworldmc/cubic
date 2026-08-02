{
  secretsAttrSet =
    pub:
    let
      inherit (pub) cubic;
    in
    {
      "cubic-ip.age".publicKeys = [ cubic ];
      "cubic-vanilla-port.age".publicKeys = [ cubic ];
      "cubic-lobby-port.age".publicKeys = [ cubic ];
      "cubic-limbo-port.age".publicKeys = [ cubic ];
      "cubic-proxy-port.age".publicKeys = [ cubic ];
    };
}
