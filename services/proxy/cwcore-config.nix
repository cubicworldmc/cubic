{ lib, culib, ... }:
{
  mysql = {
    host = "@${lib.strings.toCamelCase (culib.serviceIpSecret "mysql-server-cwcore")}@:3306";
    username = "cwcore";
    password = "@mysqlCwcoreUserPass@";
    database = "cwcore";
    ssl = true;
  };
  ignored-servers = [ "limbo" ];
  colors = {
    "reputation > 4" = "#6495ED";
    "reputation > 9" = "#7FFF00";
    "reputation > 14" = "#B8860B";
  };
  premium-permission = "group.premium";
  premium = {
    custom-color = true;
  };
  lists-tcp = {
    host = "0.0.0.0";
    port = 32000;
    key = "lists-tcp.key";
    message-timeout = 180000;
  };
  lists = {
    vanilla = {
      required-to-join = [ "vanilla" ];
      acceptance = {
        kind = "lc";
        url = "https://discord.gg/c4c7Ms5";
        key-file = "vanilla.key";
      };
    };
  };
}
