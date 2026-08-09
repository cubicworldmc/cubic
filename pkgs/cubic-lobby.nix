{
  lib,
  gradle,
  stdenvNoCC,
  fetchFromGitHub,
  jre,
  bash,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "cubic-lobby";
  version = "1.0.0";

  nativeBuildInputs = [
    gradle
  ];

  src = fetchFromGitHub {
    owner = "cubicworldmc";
    repo = "cubic-lobby";
    rev = "0627e1edf3fbe61bf371b8619ded7220fc771968";
    sha256 = "dNAAddTun9njSVd4BaWsiGoY6kGk96f1dFgLer9ksbQ=";
  };

  __darwinAllowLocalNetworking = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./cubic-lobby-deps.json;
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "shadowJar";

  doCheck = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft $out/worlds
    cp build/libs/cubic-lobby-1.0.0.jar $out/lib/minecraft/server.jar
    cp -r $src/world/lobby $out/worlds/lobby
    cat > $out/bin/lobby << EOF
    #!${bash}/bin/bash
    ${jre}/bin/java \$@ -jar $out/lib/minecraft/server.jar
    EOF
    chmod +x $out/bin/lobby
  '';

  meta = with lib; {
    license = licenses.gpl3Only;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
    ];
    mainProgram = "lobby";
  };
})
