#!/bin/bash

echo "Setting up Nextcloud with Collabora Office and MinIO S3 storage..."
echo "=================================================================="

# Function to check if Nextcloud is ready
check_nextcloud_ready() {
    echo "Checking if Nextcloud is ready..."
    docker exec nextcloud /var/www/html/occ --version >/dev/null 2>&1
    return $?
}

# Wait for Nextcloud to be ready
echo "Waiting for Nextcloud to be ready..."
while ! check_nextcloud_ready; do
    echo "Nextcloud is still starting up, waiting..."
    sleep 10
done
echo "Nextcloud is ready!"

# Install Collabora Online app
echo "Installing Collabora Online app..."
docker exec nextcloud /var/www/html/occ app:install richdocuments

# Enable Collabora Online app
echo "Enabling Collabora Online app..."
docker exec nextcloud /var/www/html/occ app:enable richdocuments

# Configure Collabora Online
echo "Configuring Collabora Online..."
docker exec nextcloud /var/www/html/occ config:app:set richdocuments wopi_url --value="http://collabora:9980"
docker exec nextcloud /var/www/html/occ config:app:set richdocuments public_wopi_url --value="http://localhost:9980"

# Set trusted domains
echo "Setting trusted domains..."
docker exec nextcloud /var/www/html/occ config:system:set trusted_domains 1 --value="localhost"
docker exec nextcloud /var/www/html/occ config:system:set trusted_domains 2 --value="nextcloud.localhost"

# Install S3 external storage app
echo "Installing S3 external storage app..."
docker exec nextcloud /var/www/html/occ app:install files_external

# Enable S3 app
echo "Enabling S3 external storage app..."
docker exec nextcloud /var/www/html/occ app:enable files_external

# Create MinIO bucket
echo "Creating MinIO bucket..."
./mc mb local/nextcloud 2>/dev/null || echo "Bucket already exists"

# Create S3 external storage configuration
echo "Configuring S3 external storage..."
docker exec nextcloud /var/www/html/occ files_external:create \
    "S3 Storage" \
    "amazons3" \
    "amazons3::accesskey" \
    -c bucket=nextcloud \
    -c hostname=minio \
    -c port=9000 \
    -c region=us-east-1 \
    -c use_ssl=false \
    -c use_path_style=true

# Get the mount ID
echo "Getting mount ID..."
MOUNT_ID=$(docker exec nextcloud /var/www/html/occ files_external:list --output=json | grep -o '"mount_id":[0-9]*' | cut -d':' -f2 | head -1)
echo "Mount ID: $MOUNT_ID"

if [ -z "$MOUNT_ID" ]; then
    echo "Error: Could not get mount ID"
    exit 1
fi

# Set S3 credentials
echo "Setting S3 credentials..."
docker exec nextcloud /var/www/html/occ files_external:config \
    $MOUNT_ID \
    amazons3::accesskey \
    minioadmin

docker exec nextcloud /var/www/html/occ files_external:config \
    $MOUNT_ID \
    amazons3::secretkey \
    minioadmin123

# Set mount point
echo "Setting mount point..."
docker exec nextcloud /var/www/html/occ files_external:config \
    $MOUNT_ID \
    mountpoint \
    "/S3 Storage"

# Make the external storage available to all users
echo "Making external storage available to all users..."
docker exec nextcloud /var/www/html/occ files_external:applicable \
    $MOUNT_ID \
    --remove-all

echo "=================================================================="
echo "Setup complete!"
echo ""
echo "Services:"
echo "- Nextcloud: http://localhost:8080 (admin/admin)"
echo "- MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
echo "- MinIO API: http://localhost:9000"
echo "- Collabora: http://localhost:9980"
echo ""
echo "Features:"
echo "✅ Collaborative document editing with Collabora Office"
echo "✅ S3-compatible storage with MinIO"
echo "✅ File sharing and synchronization"
echo ""
echo "To test:"
echo "1. Go to http://localhost:8080 and login"
echo "2. Create documents for collaborative editing"
echo "3. Upload files to S3 storage (appears as 'S3 Storage' folder)"
echo "4. Share files and folders with other users"
echo ""
echo "Note: If 'S3 Storage' folder is not visible, configure it via web interface:"
echo "Settings > External storage > Add external storage"