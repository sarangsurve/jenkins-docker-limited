#!/bin/bash

# Default values
PORT=8080
RAM="1g"
DISK_SIZE_GB=8
IMAGE_NAME="jenkins/jenkins:lts"
CONTAINER_NAME="jenkins"
DISK_IMG="$HOME/jenkins_volume.img"
MOUNT_DIR="$HOME/jenkins_volume"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --port) PORT="$2"; shift ;;
        --ram) RAM="$2"; shift ;;
        --disk) DISK_SIZE_GB="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Display settings
echo "🚀 Starting Jenkins with:"
echo " - Port: $PORT"
echo " - RAM: $RAM"
echo " - Disk Size: ${DISK_SIZE_GB}GB"

# Step 1: Pull Jenkins Docker image
echo "📦 Pulling Jenkins image..."
docker pull $IMAGE_NAME

# Step 2: Create loopback disk image if not already
if [ ! -f "$DISK_IMG" ]; then
    echo "💾 Creating $DISK_SIZE_GB GB disk image at $DISK_IMG..."
    fallocate -l ${DISK_SIZE_GB}G "$DISK_IMG"
    mkfs.ext4 "$DISK_IMG"
fi

# Step 3: Mount loopback disk
if ! mountpoint -q "$MOUNT_DIR"; then
    echo "🔗 Mounting disk image..."
    mkdir -p "$MOUNT_DIR"
    sudo mount -o loop "$DISK_IMG" "$MOUNT_DIR"
    sudo chown -R $USER:$USER "$MOUNT_DIR"
fi

# Step 4: Stop and remove any existing Jenkins container (but not data)
if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
    echo "🛑 Stopping existing Jenkins container..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Step 5: Run Jenkins container with RAM and disk limits
echo "🐳 Starting Jenkins container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8080 -p 50000:50000 \
    -v "$MOUNT_DIR":/var/jenkins_home \
    --memory="$RAM" --memory-swap="$RAM" \
    $IMAGE_NAME

echo "✅ Jenkins is running at http://localhost:$PORT"
