{
  "localhost-magic.age" = "localhost";
  "cubic-ip.age" = "localhost";
  "cubic-proxy-port.age" = "25565";
  "cubic-vanilla-port.age" = "25566";
  "cubic-lobby-port.age" = "25567";
  "cubic-limbo-port.age" = "25568";
  "forwarding-secret.age" = "forwarding-secret";
  "cwcore-ssl-key.age" = builtins.readFile ./cwcore-ssl-key.pem;
  "cwcore-ssl-cert.age" = builtins.readFile ./cwcore-ssl-cert.pem;
  "cwcore-ssl-client-key.age" = builtins.readFile ./cwcore-ssl-client-key.pem;
  "cwcore-ssl-client-cert.age" = builtins.readFile ./cwcore-ssl-client-cert.pem;
  "cwcore-vanilla-list-key.age" = builtins.readFile ./cwcore-vanilla-list-key;
  "mysql-cwcore-user-pass.age" = "mysql-cwcore-user-pass-32132131231";
  "mysql-cubicauth-user-pass.age" = "mysql-cubicauth-user-pass-39999";
  "mysql-luckperms-user-pass.age" = "mysql-luckperms-user-pass-9099";
  "clickhouse-prism-user-pass.age" = "clickhouse-prism-user-pass-399";
  "clickhouse-tcp-port.age" = "9000";
  "clickhouse-http-port.age" = "8123";
}
