{
  fetchurl,
  lib,
}:
fetchurl {
  url = "https://cdn.modrinth.com/data/TsLS8Py5/versions/wXS6bHiC/SkinsRestorer.jar";
  sha256 = "vxP/7pu0iBQbfsmWA+vIq6xomTPXLbFeZk/rC03u/GA=";
  meta.license = with lib; licenses.gpl3Only;
}
