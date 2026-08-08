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
    rev = "bc5cbf119d9af7e98e4d4443c3ddf3ac8063f395";
    sha256 = "7yyIEp5iji9FWJjz8B5V2ub4uI9Dr4KjdB+E6nRpW+A=";
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
