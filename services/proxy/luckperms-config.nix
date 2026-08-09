{ lib, culib, ... }:
{
  storage-method = "mariadb";
  data = {
    address = "@${lib.strings.toCamelCase (culib.serviceIpSecret "mysql-server-luckperms")}@:3306";
    database = "luckperms";
    username = "luckperms";
    password = "@mysqlLuckpermsUserPass@";
  };
  messaging-service = "sql";
  auto-push-updates = true;
  push-log-entries = true;
  broadcast-received-log-entries = false;
}
