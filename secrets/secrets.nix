{
  secretsAttrSet =
    pub:
    let
      inherit (pub) cubic;
    in
    {
      "localhost-magic.age".publicKeys = builtins.attrValues pub;
      "cubic-ip.age".publicKeys = [ cubic ];
      "cubic-vanilla-port.age".publicKeys = [ cubic ];
      "cubic-lobby-port.age".publicKeys = [ cubic ];
      "cubic-limbo-port.age".publicKeys = [ cubic ];
      "cubic-proxy-port.age".publicKeys = [ cubic ];
      "forwarding-secret.age".publicKeys = [ cubic ];
      "cwcore-ssl-key.age".publicKeys = [ cubic ];
      "cwcore-ssl-cert.age".publicKeys = [ cubic ];
      "cwcore-ssl-client-key.age".publicKeys = [ cubic ];
      "cwcore-ssl-client-cert.age".publicKeys = [ cubic ];
      "cwcore-vanilla-list-key.age".publicKeys = [ cubic ];
      "mysql-cwcore-user-pass.age".publicKeys = [ cubic ];
    };
}
