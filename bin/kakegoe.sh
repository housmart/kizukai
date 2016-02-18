#! /bin/bash
_DIRPATH="$(dirname $0)"
VOICE_NAME="$1"
echo ${VOICE_NAME}

# say -v Kyoko "あのおおお、すいませえええええええええええん"
# afplay ${_DIRPATH}/../data/audio/beer_tsuika4.m4a
afplay ${_DIRPATH}/../data/audio/${VOICE_NAME}.m4a
