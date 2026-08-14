{
  lib,
  bash,
  jre,
  fetchurl,
  stdenvNoCC,
}:
let
  major = "26.2";
  minor = "66";
in
stdenvNoCC.mkDerivation {
  name = "Leaf";
  version = "${major}-${minor}";

  src = fetchurl {
    url = "https://api.leafmc.one/v2/projects/leaf/versions/${major}/builds/${minor}/downloads/leaf-${major}-${minor}.jar";
    sha256 = "2de813313809b9f45a65cef6c6e5732550db7ab49a5b354b5ba901d6f6ff486a";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp $src $out/lib/minecraft/server.jar
    cat > $out/bin/leaf << EOF
    #!${bash}/bin/bash
    ${jre}/bin/java \$@ -jar $out/lib/minecraft/server.jar
    EOF
    chmod +x $out/bin/leaf
  '';

  meta = with lib; {
    license = licenses.gpl3Only;
    mainProgram = "leaf";
  };
}
