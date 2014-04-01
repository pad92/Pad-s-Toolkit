#!/usr/bin/env sh

BIN_DEPS='ffmpeg'

# === CHECKS ===
for BIN in $BIN_DEPS; do
    which $BIN 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Required file could not be found: $BIN"
        exit 1
    fi
done

if [ ! -f "$1" ]; then
    echo "Usage : youtubeEncode file_2_encode.ext"
    exit 2
fi

# === INIT ===
INPUT=$1
OUTPUT=$(echo $INPUT | sed 's/ /_/g')
OUTPUTFN=$(basename "$OUTPUT")
OUTPUT_OK="${OUTPUTFN%.*}.mp4"

if [ -f "$OUTPUT_OK" ]; then
    OUTPUT="tmp_$OUTPUT_OK"
    CLEAN="true"
else
    OUTPUT=$OUTPUT_OK
    CLEAN="false"
fi

# === CORE ===
ffmpeg -y -i $INPUT -b:v 2500k -vcodec libx264 -pass 1 -preset slow -crf 18 -r 25 -pix_fmt yuv420p -an -f mp4 /dev/null &&
ffmpeg    -i $INPUT -b:v 2500k -vcodec libx264 -pass 2 -preset slow -crf 18 -r 25 -pix_fmt yuv420p -acodec libfaac -ac 2 -ar 44100 -ab 128k $OUTPUT || exit 1

if [[ "$CLEAN" == "true" ]]; then
    mv $OUTPUT $OUTPUT_OK
else
    rm $INPUT
fi
exit 0
