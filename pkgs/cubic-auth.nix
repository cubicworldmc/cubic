{
  lib,
  gradle,
  stdenvNoCC,
  fetchFromGitHub,
}:
# TODO: CubicAuth is extremely old, it doesn't align with how cubic should be.
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "CubicAuth";
  version = "1.0";

  nativeBuildInputs = [
    gradle
  ];

  src = fetchFromGitHub {
    owner = "Jenya705";
    repo = "CubicAuth";
    rev = "52efa538883e4134921ebafe8cb24e57992b497d";
    sha256 = "sqYUcNv6KZm5TvCfJwTLJDXki5eFLIibo4eLJRp+4fU=";
  };

  __darwinAllowLocalNetworking = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./cubic-auth-deps.json;
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleBuildTask = "shadowJar";

  doCheck = true;

  installPhase = ''
    cp build/libs/CubicAuth-1.0-all.jar $out
  '';

  meta = with lib; {
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
