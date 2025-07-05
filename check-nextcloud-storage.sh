#!/bin/bash

echo "Checking Nextcloud Storage Configuration"
echo "======================================="

echo ""
echo "1. External Storage Mounts:"
docker exec nextcloud /var/www/html/occ files_external:list

echo ""
echo "2. Files External App Status:"
docker exec nextcloud /var/www/html/occ app:list | grep files_external

echo ""
echo "3. Files External App Configuration:"
docker exec nextcloud /var/www/html/occ config:app:get files_external

echo ""
echo "4. Testing MinIO Connection:"
docker exec nextcloud curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://minio:9000

echo ""
echo "5. MinIO Bucket Status:"
./mc ls local/nextcloud

echo ""
echo "======================================="
echo "Nextcloud URL: http://localhost:8080"
echo "Login: admin/admin"
echo ""
echo "Look for 'S3 Storage' folder in the file list."
echo "If not visible, the external storage may need web interface configuration."