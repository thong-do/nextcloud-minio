# GitLab OAuth2 Application Settings Reference

## GitLab OAuth2 Application Configuration

### Application Name
```
Nextcloud Social Login
```

### Redirect URI
```
http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab
```

### Scopes
```
read_user openid email profile
```

### Trusted
```
Yes (check this box)
```

## Nextcloud Social Login Provider Settings

### Provider Configuration
- **Name**: `GitLab`
- **Client ID**: `[Your GitLab Client ID]`
- **Client Secret**: `[Your GitLab Client Secret]`
- **Authorization Endpoint**: `https://gitlab.com/oauth/authorize`
- **Token Endpoint**: `https://gitlab.com/oauth/token`
- **User Info Endpoint**: `https://gitlab.com/api/v4/user`
- **Scope**: `read_user openid email profile`

## Quick Setup Checklist

### GitLab Side (https://gitlab.com)
- [ ] Go to User Settings → Applications
- [ ] Create new OAuth2 application
- [ ] Set Application Name: "Nextcloud Social Login"
- [ ] Set Redirect URI: `http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab`
- [ ] Set Scopes: `read_user openid email profile`
- [ ] Check "Trusted" box
- [ ] Save and copy Client ID and Client Secret

### Nextcloud Side (http://localhost:8080)
- [ ] Login as admin
- [ ] Go to Settings → Administration → Social Login
- [ ] Click "Add custom OAuth2 provider"
- [ ] Fill in all the provider details above
- [ ] Save the provider
- [ ] Copy the redirect URI shown (should match the one above)

### Testing
- [ ] Logout from Nextcloud
- [ ] Go to login page
- [ ] Verify "Login with GitLab" button appears
- [ ] Test the OAuth2 flow

## Troubleshooting

### Common Issues
1. **Redirect URI mismatch**: Use exact URI from Nextcloud
2. **404 errors**: Make sure Social Login app is enabled
3. **No login button**: Clear browser cache and logout completely
4. **Scope errors**: Use exactly: `read_user openid email profile`

### Verification Commands
```bash
# Check if Social Login app is enabled
docker exec nextcloud /var/www/html/occ app:list --shipped=false | grep sociallogin

# Test Social Login routes
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8080/index.php/apps/sociallogin/custom_oauth2/GitLab
```

## Notes
- The redirect URI must be exactly as shown in Nextcloud
- Don't add trailing slashes to the redirect URI
- The Social Login app must be enabled for the routes to work
- GitLab OAuth2 applications are tied to your GitLab account