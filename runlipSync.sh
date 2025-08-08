#!/bin/bash
# Usage: docker run ... inputs/video.mp4 inputs/audio.wav

FACE_VIDEO="$1"
AUDIO_WAV="$2"
AUDIO_PREP="inputs/audio_prepped.wav"
PROCESSED_FACE="inputs/face512.mp4"
OUTPUT_RAW="results/output_raw.mp4"
OUTPUT_UPSCALED="results/output_final.mp4"

mkdir -p inputs results

echo "🎥 Preprocessing face video..."
ffmpeg -y -i "$FACE_VIDEO" -t 10 \
  -vf "crop=min(iw\,ih):min(iw\,ih),scale=512:512,format=yuv420p" \
  -c:v libx264 -c:a aac "$PROCESSED_FACE"

echo "🎧 Preparing audio..."
ffmpeg -y -i "$AUDIO_WAV" -ar 16000 -ac 1 -c:a pcm_s16le "$AUDIO_PREP"

echo "🧠 Running Wav2Lip inference..."
python3 inference.py \
  --checkpoint_path checkpoints/wav2lip_gan.pth \
  --face "$PROCESSED_FACE" \
  --audio "$AUDIO_PREP" \
  --outfile "$OUTPUT_RAW" \
  --resize_factor 1 \
  --fps 25

echo "✨ Upscaling output video..."
ffmpeg -y -i "$OUTPUT_RAW" \
  -vf "scale=1280:trunc(ow/a/2)*2,unsharp=5:5:1.0" \
  -c:v libx264 -crf 18 -preset veryslow -c:a copy "$OUTPUT_UPSCALED"

echo "✅ Done! Final video saved to: $OUTPUT_UPSCALED"
