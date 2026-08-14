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
      "cwcore-lists-tcp-server-port.age".publicKeys = [ cubic ];
      "cwcore-lists-tcp-server-key.age".publicKeys = [ cubic ];
      "cwcore-vanilla-list-key.age".publicKeys = [ cubic ];
      "mysql-cwcore-user-pass.age".publicKeys = [ cubic ];
      "mysql-cubicauth-user-pass.age".publicKeys = [ cubic ];
      "mysql-luckperms-user-pass.age".publicKeys = [ cubic ];
      "mysql-skinsrestorer-user-pass.age".publicKeys = [ cubic ];
      "clickhouse-prism-user-pass.age".publicKeys = [ cubic ];
      "clickhouse-http-port.age".publicKeys = [ cubic ];
      "clickhouse-tcp-port.age".publicKeys = [ cubic ];
    };
}
