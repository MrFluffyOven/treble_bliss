#!/bin/bash

echo
echo "--------------------------------------"
echo "         Bliss 14.0 Uploadbot         "
echo "          Written by Ponces           "
echo "        Edited by MrFluffyOven        "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_bliss
BD=$HOME/builds
TAG="$(date +v%Y.%m.%d)"
GUSER="MrFluffyOven"
GREPO="treble_bliss"

createRelease() {
    echo "--> Creating release $TAG"
    res=$(curl -s -L -X POST \
        "https://api.github.com/repos/$GUSER/$GREPO/releases" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_API_TOKEN" \
        -d "{\"tag_name\":\"$TAG\",\"name\":\"BLISS 14.0 $TAG\",\"body\":\"## Changelog\n- ...\n\n## Notes\n- ...\",\"draft\":true}")
    id=$(echo "$res" | jq -rc ".id")
    echo
}

uploadAssets() {
    buildDate="$(date +%Y%m%d)"
    find $BD/ -name "bliss-*-14.0-$buildDate.img.xz" | while read file; do
        echo "--> Uploading $(basename $file)"
        curl -o /dev/null -s -L -X POST \
            "https://uploads.github.com/repos/$GUSER/$GREPO/releases/$id/assets?name=$(basename $file)" \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $GITHUB_API_TOKEN" \
            -H "Content-Type: application/octet-stream" \
            -T "$file"
        echo
    done
}

updateOta() {
    echo "--> Updating OTA file"
    pushd "$BL"
    git add config/ota.json
    git commit -m "build: Bump OTA to $TAG"
    git push
    popd
    echo
}

START=$(date +%s)

createRelease
uploadAssets
updateOta

END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Uploadbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
