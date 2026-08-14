{ culib, lib, ... }:
{
  storage = {
    skinExpiresAfter = 60;
    uuidExpiresAfter = 240;
  };
  commands = {
    skinChangeCooldown = 5;
    skinErrorCooldown = 5;
    skullCooldown = 5;
    skullErrorCooldown = 5;
    restrictSkinUrls = {
      enabled = true;
      list = [
        "https://i.imgur.com"
        "https://storage.googleapis.com"
        "https://textures.minecraft.net"
      ];
    };
    customPlayerHistory = 2;
    customFavourites = 18;
  };
  server.sound.enabled = false;
  proxy.notAllowedCommandServers.list = [ "reg-limbo" ];
  database = {
    enabled = true;
    host = "@${lib.strings.toCamelCase (culib.serviceIpSecret "mysql-server-skinsrestorer")}@";
    port = "3306";
    database = "skinsrestorer";
    username = "skinsrestorer";
    password = "@mysqlSkinsrestorerUserPass@";
    maxPoolSize = 5;
  };
}
