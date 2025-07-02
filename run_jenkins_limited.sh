#!/bin/bash

# Default values
PORT=8080
RAM="1g"
DISK_SIZE_GB=8
IMAGE_NAME="jenkins/jenkins:lts"
CONTAINER_NAME="jenkins"
MOUNT_DIR="$HOME/jenkins_volume"
USE_CUSTOM_MOUNT=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --port) PORT="$2"; shift ;;
        --ram) RAM="$2"; shift ;;
        --disk) DISK_SIZE_GB="$2"; shift ;;
        --mount-dir) MOUNT_DIR="$2"; USE_CUSTOM_MOUNT=true; shift ;;
        *) echo "❌ Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

DISK_IMG="$MOUNT_DIR/jenkins_volume.img"

# Display settings
echo "🚀 Starting Jenkins with:"
echo " - Port: $PORT"
echo " - RAM: $RAM"
echo " - Disk Size: ${DISK_SIZE_GB}GB"
echo " - Mount Dir: $MOUNT_DIR"

# Step 1: Pull Jenkins Docker image
echo "📦 Pulling Jenkins image..."
docker pull $IMAGE_NAME

# Step 2: Create mount directory
mkdir -p "$MOUNT_DIR"

# Step 3: Create loopback disk image if not present
if [ ! -f "$DISK_IMG" ]; then
    echo "💾 Creating $DISK_SIZE_GB GB disk image at $DISK_IMG..."
    fallocate -l ${DISK_SIZE_GB}G "$DISK_IMG"
    mkfs.ext4 "$DISK_IMG"
fi

# Step 4: Mount loopback disk image if not already mounted
if ! mountpoint -q "$MOUNT_DIR"; then
    echo "🔗 Mounting $DISK_IMG to $MOUNT_DIR..."
    sudo mount -o loop "$DISK_IMG" "$MOUNT_DIR"
    sudo chown -R $USER:$USER "$MOUNT_DIR"
fi

# Step 5: Stop and remove any existing Jenkins container (if exists but not data)
if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
    echo "🛑 Stopping and removing existing container..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Step 5: Run Jenkins container with RAM, disk limits and mount directory
echo "🐳 Starting Jenkins container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8080 -p 50000:50000 \
    -v "$MOUNT_DIR":/var/jenkins_home \
    --memory="$RAM" --memory-swap="$RAM" \
    $IMAGE_NAME

echo "✅ Jenkins is running at http://localhost:$PORT"

# Clean up loopback image if default mount dir was used
if ! $USE_CUSTOM_MOUNT; then
    echo "🧼 To remove Jenkins completely, run:"
    echo "   docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
    echo "   sudo umount $MOUNT_DIR && rm -rf $MOUNT_DIR $DISK_IMG"
fi
