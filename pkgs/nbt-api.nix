{
  fetchurl,
  lib,
}:
fetchurl {
  url = "https://cdn.modrinth.com/data/nfGCP9fk/versions/GYdTPugT/item-nbt-api-plugin-2.16.0.jar";
  sha256 = "78qzKiEe/mCyiogND6GMCyMVsJ5AAsGu+Jq0ybeO26I=";
  meta = with lib; {
    license = licenses.mit;
  };
}
