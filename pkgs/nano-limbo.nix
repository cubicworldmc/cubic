{
  lib,
  bash,
  jre,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  name = "NanoLimbo";
  version = "1.13.0";

  src = fetchurl {
    url = "https://github.com/Nan1t/NanoLimbo/releases/download/v1.13.0/NanoLimbo.jar";
    sha256 = "iE3D1JQfsJZN/TSM68Zq+2krFWohPMmA1vR/AkQUMs8=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp $src $out/lib/minecraft/server.jar
    cat > $out/bin/limbo << EOF
    #!${bash}/bin/bash
    ${jre}/bin/java \$@ -jar $out/lib/minecraft/server.jar
    EOF
    chmod +x $out/bin/limbo
  '';
  meta = with lib; {
    license = licenses.gpl3Only;
    mainProgram = "limbo";
  };
}
