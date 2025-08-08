FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip ffmpeg git build-essential curl \
    libglib2.0-0 libsm6 libxrender1 libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace/Wav2Lip

# Copy all files into the container
COPY . .

# Upgrade pip and install Python dependencies
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install -r requirements.txt

# Optional: download model checkpoints (if not mounting)
# RUN curl -L -o checkpoints/wav2lip_gan.pth https://github.com/Rudrabha/Wav2Lip/releases/download/v1.0/wav2lip_gan.pth

# Set default command
ENTRYPOINT ["python3", "inference.py"]
