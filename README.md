# Chrome Manifest V2 Policy Manager

## 📌 What This Tool Does

Google Chrome is phasing out Manifest V2 extensions and replacing them with Manifest V3, which breaks many older extensions. This tool lets you control a hidden Chrome policy called **ExtensionManifestV2Availability**, which can allow Manifest V2 extensions to keep working — just like some apps (e.g., IDM) do.

By changing this policy, Chrome will think it’s managed by an organization and will allow certain blocked extensions.

**⚠ Note:** This change is local to your computer and does **not** let anyone (like your office or Google) see your browsing history.

---

## 🖥 Requirements

* **Windows** (tested on Windows 10/11)
* **Google Chrome** (or Chromium) installed
* **Administrator privileges** (you must run the script as admin)

---

## 📥 How to Use

1. **Download the script** (`run.bat`).
2. **Right-click** the file and select **"Run as administrator"**.
3. In the menu that appears, choose:

   * **Option 3** → `Enable (Allow all MV2 extensions)`
4. Follow the on-screen prompts.
5. **Restart Chrome** for changes to take effect.
6. To check if it worked:

   * Open Chrome
   * Go to `chrome://policy`
   * Look for **ExtensionManifestV2Availability** set to `2`

---

## 📜 Menu Options Explained

| Option                | What It Does                                                        |
| --------------------- | ------------------------------------------------------------------- |
| **1 - Default**       | Follows Google’s deprecation schedule (normal Chrome behavior)      |
| **2 - Disable**       | Blocks all Manifest V2 extensions                                   |
| **3 - Enable**        | Allows **all** Manifest V2 extensions (recommended to bypass block) |
| **4 - Forced Only**   | Allows only extensions installed by enterprise policy               |
| **5 - Remove**        | Deletes the policy and restores Chrome to normal                    |
| **6 - Info**          | Shows detailed explanation of the policy                            |
| **7 - Check Install** | Checks if Chrome/Chromium is installed and running                  |
| **8 - Exit**          | Closes the script                                                   |

---

## 🔄 How to Undo the Change

If you no longer need Manifest V2 extensions:

1. Run the script again as Administrator
2. Choose **Option 5** → `Remove policy`
3. Restart Chrome

---

## ⚠ Important Notes

* Chrome will show **"Managed by your organization"** in the menu after enabling this — this is normal.
* This method may stop working in the future if Google fully removes Manifest V2 support from the browser.
* Some extensions may still not work if Google blocks them for security reasons.

---

