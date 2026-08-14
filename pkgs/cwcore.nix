{
  lib,
  gradle,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "cwcore";
  version = "1.0.0";

  nativeBuildInputs = [
    gradle
  ];

  src = fetchFromGitHub {
    owner = "cubicworldmc";
    repo = "cwcore";
    rev = "d2a716804700b3c803650feedee49449626f2f6e";
    sha256 = "HI0q3eykm1fUk6k9j+CVBoC/VO/9MQkIMY7aX8ZikrQ=";
  };

  __darwinAllowLocalNetworking = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./cwcore-deps.json;
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "shadowJar";

  doCheck = true;

  installPhase = ''
    mkdir $out
    cp core-bukkit/build/libs/core-bukkit-all.jar $out/bukkit.jar
    cp core-velocity/build/libs/core-velocity-all.jar $out/velocity.jar
  '';

  meta = with lib; {
    license = licenses.agpl3Only;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
