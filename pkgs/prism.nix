{
  lib,
  gradle,
  stdenvNoCC,
  fetchFromGitHub,
}:
let
  rev = "a2a8fc70aaf40b6e3c954049422911a4d0c3e693";
in
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "prism";
  version = "nix-${rev}";

  nativeBuildInputs = [
    gradle
  ];

  src = fetchFromGitHub {
    owner = "prism";
    repo = "prism";
    inherit rev;
    sha256 = "2KN8rrU/56Nq43AZqhSAt/bwdW81SnO418hlvMZgjKE=";
  };

  __darwinAllowLocalNetworking = true;

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./prism-deps.json;
  };

  gradleFlags = [
    "-Dfile.encoding=utf-8"
    "-PskipWeb"
  ];

  gradleBuildTask = "build";

  doCheck = true;

  patches = [
    ./prism-version-patch.diff
    # Without the patch, gradle/nix bugs and cannot find the right paper version.
    ./prism-paper-api-version-patch.diff
  ];

  preBuild = ''
    export __PRISM_VERSION=${version}
  '';

  installPhase = ''
    cp prism-paper-loader/build/libs/prism-paper-${version}.jar $out
  '';

  meta = with lib; {
    license =
      with licenses;
      OR [
        gpl3
        mit
      ];
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
