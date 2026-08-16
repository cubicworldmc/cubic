{
  lib,
  gradle,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "minecraft-script-hooks";
  version = "0.0-SNAPSHOT";

  nativeBuildInputs = [
    gradle
  ];

  src = fetchFromGitHub {
    owner = "cubicworldmc";
    repo = "minecraft-script-hooks";
    rev = "07d03c8df99f178d2ba885c521ae576d6598c353";
    sha256 = "3PbbpBTUxkfbP5hshPxLpK9/pfsi5Kxbj8s7UVxGbL4=";
  };

  __darwinAllowLocalNetworking = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./minecraft-script-hooks-deps.json;
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "build";

  doCheck = true;

  installPhase = ''
    cp build/libs/minecraft-script-hooks-${version}.jar $out
  '';

  meta = with lib; {
    license = licenses.gpl3Only;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
