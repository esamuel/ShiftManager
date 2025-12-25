# 🌐 How to Upload Your Website to shiftsmanager.com (GoDaddy)

## 📋 Complete Step-by-Step Guide with Screenshots

---

## Method 1: GoDaddy File Manager (Easiest - Recommended)

### Step 1: Log in to GoDaddy

1. Open your browser and go to: **https://www.godaddy.com**
2. Click **"Sign In"** (top right corner)
3. Enter your GoDaddy username and password
4. Click **"Sign In"**

---

### Step 2: Access Your Hosting

1. After logging in, you'll see the GoDaddy dashboard
2. Click on your **profile icon** (top right)
3. Select **"My Products"** from the dropdown

   OR

   Click the **"☰"** menu icon → Select **"My Products"**

---

### Step 3: Find Your Website Hosting

You should see a list of your products. Look for:

```
Web Hosting
shiftsmanager.com
```

**What to click:**
- If you see **"Manage"** button → Click it
- If you see **"Set Up"** → Click it
- If you see **"cPanel"** → Click it

---

### Step 4: Open File Manager

**Option A - If you see cPanel:**
1. Look for **"Files"** section
2. Click **"File Manager"** icon

**Option B - If you see Plesk:**
1. Look for **"Files"** in the left menu
2. Click **"File Manager"**

**Option C - If you see Website Builder:**
1. Look for **"Settings"** or **"Advanced"**
2. Find **"File Manager"** or **"FTP"**

---

### Step 5: Navigate to public_html

1. In File Manager, you'll see a folder tree on the left
2. Look for and click on: **`public_html`** folder
   - This is where your website files go
   - Sometimes called `www` or `httpdocs`

3. You might see existing files like:
   - `index.html` (the "Launching Soon" page)
   - `coming-soon.html`
   - Other files

---

### Step 6: Backup Existing Files (Optional but Recommended)

Before deleting anything:

1. **Select all existing files** in `public_html`
2. Click **"Compress"** or **"Zip"** button
3. Name it: `backup-old-site.zip`
4. Click **"Compress"**
5. **Download** the zip file to your computer

Now you have a backup!

---

### Step 7: Delete Old Files

1. **Select all files** in `public_html` (except the backup zip)
   - Click the checkbox next to each file
   - OR use "Select All" if available

2. Click **"Delete"** button
3. Confirm deletion

The folder should now be empty (except maybe the backup zip).

---

### Step 8: Upload Your New Website Files

1. Click the **"Upload"** button (usually at the top)
2. A file browser will open
3. Navigate to your computer:
   ```
   /Users/samueleskenasy/ShiftManager/website/
   ```

4. **Select these 3 files:**
   - ✅ `index.html`
   - ✅ `privacy.html`
   - ✅ `terms.html`

5. Click **"Open"** or **"Upload"**

6. Wait for upload to complete (should be very fast, files are small)

---

### Step 9: Verify Upload

You should now see in `public_html`:
```
📄 index.html
📄 privacy.html
📄 terms.html
```

**Check file permissions:**
- Right-click each file → **"Change Permissions"** or **"Chmod"**
- Set to: **644** (this means readable by everyone)
- Format: `-rw-r--r--`

---

### Step 10: Test Your Website! 🎉

1. Open a new browser tab
2. Go to: **https://shiftsmanager.com**
3. You should see your beautiful new landing page!

4. Test other pages:
   - **https://shiftsmanager.com/privacy.html**
   - **https://shiftsmanager.com/terms.html**

---

## Method 2: FTP Upload (Alternative Method)

If File Manager doesn't work, use FTP:

### Step 1: Get FTP Credentials

1. In GoDaddy, go to your hosting
2. Look for **"FTP"** or **"FTP Accounts"**
3. You'll see:
   - **FTP Host:** Usually `ftp.shiftsmanager.com`
   - **Username:** (your FTP username)
   - **Password:** (click "Show" or reset it)
   - **Port:** 21

Write these down!

---

### Step 2: Download FTP Client

**FileZilla (Free & Easy):**
1. Go to: https://filezilla-project.org
2. Download **FileZilla Client** (NOT Server)
3. Install it on your Mac

---

### Step 3: Connect to Your Server

1. Open FileZilla
2. At the top, enter:
   - **Host:** `ftp.shiftsmanager.com`
   - **Username:** [your FTP username]
   - **Password:** [your FTP password]
   - **Port:** `21`

3. Click **"Quickconnect"**

---

### Step 4: Upload Files via FTP

**Left side** = Your computer
**Right side** = Your server

1. On the **right side**, navigate to `public_html` folder
2. On the **left side**, navigate to:
   ```
   /Users/samueleskenasy/ShiftManager/website/
   ```

3. **Drag and drop** these files from left to right:
   - `index.html`
   - `privacy.html`
   - `terms.html`

4. If asked to overwrite, click **"Yes"**

---

## 🔍 Troubleshooting

### Problem: "I don't see File Manager"

**Solution:**
- Try accessing cPanel directly: `https://shiftsmanager.com:2083`
- Or contact GoDaddy support to enable File Manager

---

### Problem: "Website still shows old 'Launching Soon' page"

**Solutions:**
1. **Clear browser cache:**
   - Mac: `Cmd + Shift + R` (hard refresh)
   - Or open in Incognito/Private mode

2. **Wait 5-10 minutes:**
   - Sometimes changes take a few minutes to propagate

3. **Check you uploaded to correct folder:**
   - Must be in `public_html`, not a subfolder

---

### Problem: "404 Not Found on privacy.html or terms.html"

**Solutions:**
1. **Check file names are correct:**
   - Must be lowercase: `privacy.html` (not `Privacy.html`)
   - No extra spaces

2. **Check file permissions:**
   - Should be 644

3. **Verify files are in `public_html`:**
   - Not in a subfolder

---

### Problem: "Permission Denied"

**Solution:**
- Contact GoDaddy support
- They may need to reset your hosting permissions

---

## 📱 After Upload: Update App Store Connect

Once your website is live:

1. Go to: **https://appstoreconnect.apple.com**
2. Sign in with your Apple Developer account
3. Select **"My Apps"**
4. Select **"ShiftManager"** (or create new app)
5. Go to **"App Information"** tab
6. Scroll to **"Privacy Policy URL"**
7. Enter: `https://shiftsmanager.com/privacy.html`
8. If there's a **"Terms of Service URL"** field, enter: `https://shiftsmanager.com/terms.html`
9. Click **"Save"**

---

## ✅ Final Checklist

After upload, verify:

- [ ] https://shiftsmanager.com loads the landing page
- [ ] https://shiftsmanager.com/privacy.html loads privacy policy
- [ ] https://shiftsmanager.com/terms.html loads terms of service
- [ ] All links in navigation work
- [ ] Website looks good on mobile (test on iPhone)
- [ ] No broken images or links
- [ ] Contact emails are mentioned correctly

---

## 🎨 Optional: Add Favicon

To add the app icon to your website:

1. Export your app icon as `favicon.ico` (16x16 or 32x32 pixels)
2. Upload it to `public_html` folder
3. It will automatically appear in browser tabs

---

## 📧 Optional: Set Up Email Forwarding

To make `support@shiftsmanager.com` work:

1. In GoDaddy, go to **"Email & Office"**
2. Click **"Manage"** next to your domain
3. Click **"Create Email Address"**
4. Create: `support@shiftsmanager.com`
5. Set up **forwarding** to your personal email
6. Repeat for `privacy@shiftsmanager.com`

---

## 🆘 Need More Help?

**GoDaddy Support:**
- Phone: 1-480-505-8877
- Chat: Available in your GoDaddy dashboard
- Help Center: https://www.godaddy.com/help

**Common GoDaddy Help Articles:**
- "How to upload files to my website"
- "How to access File Manager"
- "How to use FTP"

---

## 🎉 You're Done!

Once uploaded, your website is **LIVE** and ready for:
- ✅ App Store submission
- ✅ User visits
- ✅ Google indexing
- ✅ Professional presence

**Congratulations on your website launch!** 🚀

---

## 📸 Quick Visual Reference

```
GoDaddy Dashboard
    ↓
My Products
    ↓
Web Hosting → Manage
    ↓
File Manager (or cPanel)
    ↓
public_html folder
    ↓
Upload files
    ↓
Done! 🎉
```

---

**Need help?** The files are ready in:
`/Users/samueleskenasy/ShiftManager/website/`

Just drag and drop them into GoDaddy File Manager!
