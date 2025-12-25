# ShiftManager Website Deployment Guide

## ✅ Website Created Successfully!

Your complete professional website is ready in the `/website` folder:
- `index.html` - Landing page with features and pricing
- `privacy.html` - Privacy Policy (required by Apple)
- `terms.html` - Terms of Service (required by Apple)

---

## 🚀 How to Deploy to shiftsmanager.com (GoDaddy)

### Method 1: GoDaddy File Manager (Easiest)

1. **Log in to GoDaddy**
   - Go to https://www.godaddy.com
   - Sign in to your account

2. **Access File Manager**
   - Go to "My Products"
   - Find your hosting plan
   - Click "Manage" → "cPanel" or "File Manager"

3. **Upload Files**
   - Navigate to `public_html` folder
   - Delete or backup existing files
   - Upload all 3 files:
     - `index.html`
     - `privacy.html`
     - `terms.html`

4. **Test**
   - Visit https://shiftsmanager.com
   - Check all pages load correctly

### Method 2: FTP Upload (Recommended for Developers)

1. **Get FTP Credentials**
   - GoDaddy Dashboard → Hosting → Manage
   - Find FTP credentials or create new FTP account

2. **Use FTP Client**
   - Download FileZilla (free): https://filezilla-project.org
   - Connect using your FTP credentials:
     - Host: ftp.shiftsmanager.com
     - Username: [your FTP username]
     - Password: [your FTP password]
     - Port: 21

3. **Upload Files**
   - Navigate to `public_html` folder
   - Upload all 3 HTML files

### Method 3: Git Deployment (Advanced)

If you want automatic deployments:
1. Create a GitHub repository
2. Push website files
3. Set up GoDaddy Git integration (if available)

---

## 📱 App Store Connect Setup

Once deployed, add these URLs to App Store Connect:

1. **Go to App Store Connect**
   - https://appstoreconnect.apple.com
   - Select your app

2. **Add URLs**
   - App Information → Privacy Policy URL:
     ```
     https://shiftsmanager.com/privacy.html
     ```
   
   - App Information → Terms of Service URL (if field exists):
     ```
     https://shiftsmanager.com/terms.html
     ```

3. **Save Changes**

---

## ✅ Pre-Deployment Checklist

Before uploading:
- [ ] Domain is active (shiftsmanager.com) ✓
- [ ] All 3 HTML files are ready ✓
- [ ] Privacy Policy is complete ✓
- [ ] Terms of Service is complete ✓
- [ ] Contact emails mentioned (support@shiftsmanager.com)
- [ ] Pricing matches your App Store setup

---

## 📧 Email Setup (Optional but Recommended)

Set up professional emails:
- support@shiftsmanager.com
- privacy@shiftsmanager.com

**In GoDaddy:**
1. Go to "Email & Office"
2. Create email addresses
3. Set up forwarding to your personal email

---

## 🎨 Customization Options

### Add App Store Badge
When your app is live, add the download button:

```html
<a href="YOUR_APP_STORE_LINK">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" 
         alt="Download on App Store" 
         style="height: 60px;">
</a>
```

Replace the `#` in the "Download on App Store" button with your actual App Store link.

### Add Screenshots
Replace the placeholder in `index.html`:
```html
<div class="screenshot-placeholder">
    📱 App Screenshots Coming Soon
</div>
```

With actual screenshots:
```html
<img src="screenshot1.png" alt="ShiftManager Screenshot" style="max-width: 100%; border-radius: 20px;">
```

---

## 🔍 Testing After Deployment

1. **Visit all pages:**
   - https://shiftsmanager.com
   - https://shiftsmanager.com/privacy.html
   - https://shiftsmanager.com/terms.html

2. **Test on mobile:**
   - Open on iPhone/iPad
   - Check responsive design
   - Verify all links work

3. **Validate:**
   - Check for broken links
   - Verify email addresses work
   - Test navigation between pages

---

## 📊 Analytics (Optional)

Add Google Analytics to track visitors:

1. Create Google Analytics account
2. Get tracking code
3. Add before `</head>` in all HTML files

---

## 🎉 You're Ready!

Once deployed, your website will have:
- ✅ Professional landing page
- ✅ Complete Privacy Policy (App Store requirement)
- ✅ Complete Terms of Service (App Store requirement)
- ✅ Mobile-responsive design
- ✅ Modern, beautiful UI
- ✅ All legal requirements met

**Next Steps:**
1. Upload files to GoDaddy
2. Test the website
3. Add URLs to App Store Connect
4. Submit your app for review!

---

## 🆘 Need Help?

If you encounter issues:
1. Check GoDaddy support docs
2. Verify file permissions (should be 644)
3. Clear browser cache
4. Check if domain DNS is properly configured

Good luck with your app launch! 🚀
