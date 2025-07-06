# GitLab OAuth2 Integration with Nextcloud Social Login

## Current Status
✅ Social Login app is installed and enabled
✅ Routes are working (401 responses indicate routes exist but need auth)
❌ Need to configure through Nextcloud web interface

## Step-by-Step Setup

### 1. Access Nextcloud Admin Interface
1. Go to: http://localhost:8080
2. Login with your admin credentials
3. Go to **Settings** → **Administration** → **Social Login**

### 2. Configure GitLab Provider in Nextcloud
1. In the Social Login settings page, click **"Add custom OAuth2 provider"**
2. Fill in the following details:
   - **Name**: `GitLab`
   - **Client ID**: `your-gitlab-client-id`
   - **Client Secret**: `your-gitlab-client-secret`
   - **Authorization Endpoint**: `https://gitlab.com/oauth/authorize`
   - **Token Endpoint**: `https://gitlab.com/oauth/token`
   - **User Info Endpoint**: `https://gitlab.com/api/v4/user`
   - **Scope**: `read_user openid email profile`

### 3. Get the Correct Redirect URI
After adding the provider, the Social Login app will display the correct redirect URI. It should look like:
```
http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab
```

### 4. Update GitLab OAuth2 Application
1. Go to your GitLab instance: https://gitlab.com
2. Navigate to **User Settings** → **Applications**
3. Edit your OAuth2 application
4. Update the **Redirect URI** with the one shown in Nextcloud
5. Save the changes

### 5. Test the Integration
1. Logout from Nextcloud
2. Go to the login page
3. You should now see a **"Login with GitLab"** button
4. Click it to test the OAuth2 flow

## Troubleshooting

### If you don't see "Social Login" in admin settings:
1. Check if the app is properly enabled:
   ```bash
   docker exec nextcloud /var/www/html/occ app:list | grep sociallogin
   ```

2. Try reinstalling the app:
   ```bash
   docker exec nextcloud /var/www/html/occ app:disable sociallogin
   docker exec nextcloud /var/www/html/occ app:enable sociallogin
   ```

### If you get redirect URI errors:
1. Make sure you're using the exact URI shown in Nextcloud
2. The URI should be: `http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab`
3. Don't add any trailing slashes

### If the login button doesn't appear:
1. Make sure you're logged out completely
2. Clear your browser cache
3. Check that the provider is properly configured in Social Login settings

## Alternative: Use Built-in OAuth2 App
If the Social Login app continues to have issues, you can use Nextcloud's built-in OAuth2 app:

1. Go to **Settings** → **Administration** → **OAuth2**
2. Add a new client
3. Use the redirect URI: `http://localhost:8080/index.php/settings/admin/oauth2`
4. Configure GitLab OAuth2 application with this URI

## Environment Variables (Optional)
You can also set these environment variables in your `docker-compose.yml`:

```yaml
environment:
  - GITLAB_CLIENT_ID=your-client-id
  - GITLAB_CLIENT_SECRET=your-client-secret
  - GITLAB_DOMAIN=gitlab.com
```

## Testing Commands
Run these commands to test the setup:

```bash
# Test if Social Login app is working
docker exec nextcloud /var/www/html/occ app:list | grep sociallogin

# Test Social Login routes (should return 401, not 404)
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab
```

## Next Steps
1. Follow the web interface setup above
2. The Social Login app will show you the exact redirect URI to use
3. Update your GitLab OAuth2 application with that URI
4. Test the login flow