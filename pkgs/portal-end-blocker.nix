{
  lib,
  gradle,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "portal-end-blocker";
  version = "0.0-SNAPSHOT";

  nativeBuildInputs = [
    gradle
  ];

  src = fetchFromGitHub {
    owner = "cubicworldmc";
    repo = "portal-end-blocker";
    rev = "56339499895bdcb2b37a59cd9dbbf34b6337f5c7";
    sha256 = "L2uJbMSyNkD/hTEEs37qk372u7tFh3gFBaFsZLmfMK4=";
  };

  __darwinAllowLocalNetworking = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./portal-end-blocker-deps.json;
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "build";

  doCheck = true;

  installPhase = ''
    cp build/libs/portal-end-blocker-${version}.jar $out
  '';

  meta = with lib; {
    license = licenses.gpl3Only;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
