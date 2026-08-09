{ lib, culib, ... }: {
  sql = {
    user = "cubicauth";
    password = "@mysqlCubicauthUserPass@";
    host = "@${lib.strings.toCamelCase (culib.serviceIpSecret "mysql-server-cubicauth")}@:3306";
    database = "cubicauth";
  };
  limbo = "limbo";
}
