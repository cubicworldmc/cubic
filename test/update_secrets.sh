#!/usr/bin/env bash
set -Eeuo pipefail

VALUES_DIR=${VALUES_DIR:-./secrets/test}
VALUES=${VALUES:-./values.nix}
IDENTITY=${IDENTITY:-$(cd -- "$(dirname -- "./test/id_ed25519")"; pwd)/$(basename -- "./test/id_ed25519")}

cd $VALUES_DIR

FILES=$( (@nixInstantiate@ --json --eval -E "(let values = import $VALUES; in builtins.attrNames values)"  | @jqBin@ -r .[]) || exit 1)

for FILE in $FILES
do
  VALUE=$( (@nixInstantiate@ --json --eval -E "(let values = import $VALUES; in values.\"$FILE\")" | @jqBin@ -r .) || exit 1)
  echo "$VALUE" | @agenix@ -e $FILE -i $IDENTITY
done
