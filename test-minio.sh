#!/bin/bash

echo "Testing MinIO S3 Integration with Nextcloud"
echo "============================================"

# Configure MinIO client
echo "Configuring MinIO client..."
./mc alias set local http://localhost:9000 minioadmin minioadmin123

# List buckets
echo ""
echo "Available buckets in MinIO:"
./mc ls local

# List contents of nextcloud bucket
echo ""
echo "Contents of 'nextcloud' bucket:"
./mc ls local/nextcloud --recursive

# Create a test file
echo ""
echo "Creating a test file..."
echo "This is a test file created at $(date)" > test-file.txt

# Upload test file to MinIO directly
echo "Uploading test file directly to MinIO..."
./mc cp test-file.txt local/nextcloud/test-direct-upload.txt

# List contents again
echo ""
echo "Contents after direct upload:"
./mc ls local/nextcloud --recursive

# Clean up test file
rm test-file.txt

echo ""
echo "============================================"
echo "Test completed!"
echo ""
echo "To test Nextcloud integration:"
echo "1. Go to http://localhost:8080"
echo "2. Login with admin/admin"
echo "3. Navigate to 'S3 Storage' folder"
echo "4. Upload any file"
echo "5. Run this script again to see the file in MinIO"
echo ""
echo "MinIO Console: http://localhost:9001 (minioadmin/minioadmin123)"
echo "MinIO API: http://localhost:9000"