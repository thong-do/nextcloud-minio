# Nextcloud with Collabora Office and MinIO S3 Setup

This setup provides a complete Nextcloud instance with Collabora Office for collaborative document editing and MinIO for S3-compatible storage.

## Features
- Nextcloud with persistent storage
- Collabora (Nextcloud Office) integration
- MinIO S3-compatible storage
- GitLab OAuth2 login via Social Login app

## Quick Start

1. **Start the services:**
   ```bash
   docker-compose up -d
   ```

2. **Run the setup script:**
   ```bash
   ./setup-gitlab-oauth2-complete.sh
   ```

3. **Access the services:**
   - **Nextcloud**: http://localhost:8080 (admin/admin)
   - **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin123)
   - **MinIO API**: http://localhost:9000

## Services

- **Nextcloud**: Main file storage and collaboration platform (port 8080)
- **MariaDB**: Database for Nextcloud (internal)
- **Collabora**: Office suite for document editing (port 9980)
- **MinIO**: S3-compatible object storage (ports 9000, 9001)

## Authentication Options

- **Local accounts**: Default admin/admin login
- **GitLab OAuth2**: Login with GitLab accounts (optional)

## Testing Collaborative Editing

1. **Create a new document:**
   - Login to Nextcloud at http://localhost:8080
   - Click the "+" button and select "New document"
   - Choose from: Text document, Spreadsheet, or Presentation

2. **Share for collaboration:**
   - Right-click on the document
   - Select "Share"
   - Add another user's email or create a share link
   - Set permissions to "Can edit"

3. **Collaborative editing:**
   - Both users can now open the same document
   - Changes are synchronized in real-time
   - Multiple users can edit simultaneously

## Using S3 Storage (MinIO)

1. **Access S3 Storage:**
   - In Nextcloud, you'll see an "S3 Storage" folder
   - This folder is connected to your MinIO instance
   - Files uploaded here are stored in MinIO

2. **Manage MinIO:**
   - Access MinIO Console at http://localhost:9001
   - Login with: minioadmin / minioadmin123
   - Create buckets, manage policies, and monitor usage

3. **S3 API Access:**
   - MinIO API is available at http://localhost:9000
   - Use any S3-compatible client with these credentials:
     - Access Key: minioadmin
     - Secret Key: minioadmin123
     - Endpoint: http://localhost:9000

4. **Test S3 Integration:**
   ```bash
   ./test-minio.sh
   ```

## Troubleshooting

### Collabora shows "OK" message
This is normal - it means the service is running. The integration happens through Nextcloud, not by accessing Collabora directly.

### Documents don't open in editor
1. Check that the Collabora Online app is installed and enabled
2. Verify the WOPI URL is set correctly in Nextcloud settings
3. Ensure all containers are running: `docker-compose ps`

### S3 Storage folder not visible
1. Run the setup script: `./setup-gitlab-oauth2-complete.sh`
2. Check external storage configuration: `./check-nextcloud-storage.sh`
3. If still not visible, configure via web interface:
   - Go to Settings > External storage
   - Add external storage with Amazon S3 configuration
   - Use credentials: minioadmin/minioadmin123

### Connection issues
1. Check if all services are running: `docker-compose ps`
2. View logs: `docker-compose logs`
3. Restart services: `docker-compose restart`

## Manual Configuration (if needed)

If the setup script doesn't work, you can manually configure:

### Collabora Office
```bash
# Install Collabora Online app
docker exec nextcloud /var/www/html/occ app:install richdocuments

# Enable the app
docker exec nextcloud /var/www/html/occ app:enable richdocuments

# Configure WOPI URL
docker exec nextcloud /var/www/html/occ config:app:set richdocuments wopi_url --value="http://collabora:9980"

# Set public WOPI URL
docker exec nextcloud /var/www/html/occ config:app:set richdocuments public_wopi_url --value="http://localhost:9980"
```

### MinIO S3 Storage
```bash
# Install S3 external storage app
docker exec nextcloud /var/www/html/occ app:install files_external

# Enable S3 app
docker exec nextcloud /var/www/html/occ app:enable files_external

# Create S3 external storage
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

# Get the mount ID and configure
MOUNT_ID=$(docker exec nextcloud /var/www/html/occ files_external:list --output=json | grep -o '"mount_id":[0-9]*' | cut -d':' -f2 | head -1)

# Set credentials
docker exec nextcloud /var/www/html/occ files_external:config $MOUNT_ID amazons3::accesskey minioadmin
docker exec nextcloud /var/www/html/occ files_external:config $MOUNT_ID amazons3::secretkey minioadmin123

# Set mount point and make available to all users
docker exec nextcloud /var/www/html/occ files_external:config $MOUNT_ID mountpoint "/S3 Storage"
docker exec nextcloud /var/www/html/occ files_external:applicable $MOUNT_ID --remove-all
```

## Security Notes

- Change default passwords for production use
- Consider setting up SSL/TLS certificates
- Use strong database passwords
- Regularly update the containers
- Keep GitLab OAuth2 credentials secure
- Use environment variables for sensitive data

## Available Scripts

- **`setup.sh`** - Main setup script for both Collabora and MinIO
- **`setup-gitlab.sh`** - Setup GitLab OAuth2 authentication only
- **`setup-with-gitlab.sh`** - Complete setup with GitLab OAuth2 integration
- **`test-minio.sh`** - Test MinIO S3 integration and connectivity
- **`check-nextcloud-storage.sh`** - Check Nextcloud storage configuration
- **`mc`** - MinIO client for direct S3 operations

## File Types Supported

Collabora supports editing:
- **Documents**: .docx, .odt, .rtf, .txt
- **Spreadsheets**: .xlsx, .ods, .csv
- **Presentations**: .pptx, .odp
- **Drawings**: .odg

## GitLab OAuth2 Integration

### 1. Configure Social Login in Nextcloud
- Go to **Settings → Administration → Social Login**
- Click **Add custom OAuth2 provider**
- Fill in:
  - **Name:** `GitLab`
  - **Authorize url:** `https://gitlab.com/oauth/authorize`
  - **Token url:** `https://gitlab.com/oauth/token`
  - **User info URL:** `https://gitlab.com/api/v4/user`
  - **Client Id:** *(from your GitLab OAuth2 application)*
  - **Client Secret:** *(from your GitLab OAuth2 application)*
  - **Scope:** `read_user openid email profile`
  - **Button style:** `Gitlab`
- Save the provider

### 2. Update Redirect URI in GitLab
- After saving, Nextcloud will show a **redirect URI** (e.g., `http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab`)
- Copy this URI and paste it into your GitLab OAuth2 application's redirect URI field

### 3. Test the Integration
- Log out of Nextcloud
- Go to the login page
- You should see a **Login with GitLab** button
- Click it to test the OAuth2 flow

### Troubleshooting
- **Scope errors:** Use exactly `read_user openid email profile`
- **Redirect URI errors:** Use the exact URI shown in Nextcloud, no trailing slash
- **No login button:** Make sure Social Login app is enabled, clear browser cache, and log out completely

## More Documentation
- See `GITLAB_OAUTH2_SETUP_GUIDE.md` for a full step-by-step guide
- See `GITLAB_OAUTH2_REFERENCE.md` for a quick reference card

---

For Collabora and MinIO S3 setup, see previous sections in this README or the respective setup scripts.

https://github.com/zorn-v/nextcloud-social-login/blob/b92d2236a9df50aa3cf029c039d77bb541d3c085/docs/sso/gitlab.md