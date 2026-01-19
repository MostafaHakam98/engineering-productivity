# TamperMonkey Scripts

Browser automation scripts for common engineering workflows. These scripts enhance productivity by automating repetitive tasks and adding keyboard shortcuts to web applications.

## What's Included

### `GitLab-File-Tree.js`
Enhanced GitLab file tree sidebar with:
- **Keyboard shortcuts** for navigation
- **Quick search** functionality
- **File counts** and statistics
- **Copy path** functionality
- **Dark theme** styling
- **File type icons**

**Compatible with**: GitLab instances (configure via `.env`)

### `GitLab-Issue-MR.js`
GitLab Issue → Merge Request helper:
- **Branch name suggestions** from issue titles
- **Label pre-filling**
- **Clipboard copy** functionality
- **Keyboard shortcuts**
- **Markdown template generation**

**Compatible with**: GitLab instances (configure via `.env`)

### `ActiTime-AutoFill.js`
ActiTIME time tracking automation:
- **Auto-fill hours** for Sun–Thu (configurable)
- **Progress indicators**
- **Export functionality**
- **Undo/redo** support
- **Keyboard shortcuts** (Ctrl+Alt+F to fill)
- **Metrics and statistics**

**Compatible with**: `online.actitime.com`

## Installation

### Prerequisites

1. Install [Tampermonkey](https://www.tampermonkey.net/) browser extension:
   - [Chrome/Edge](https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)
   - [Firefox](https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/)
   - [Safari](https://apps.apple.com/us/app/tampermonkey/id1482490089)

### Automated Setup (Recommended)

1. **Configure Environment Variables**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env with your values
   # GITLAB_URL=gitlab.yourcompany.com
   # COMPANY_NAME=YourCompany
   # AUTHOR_NAME=Your Name
   # STORAGE_KEY_PREFIX=yc
   ```

2. **Run Setup Script**
   ```bash
   cd TamperMonkey
   ./setup.sh
   ```
   
   This will generate configured scripts from templates, replacing placeholders with your values.

3. **Install in Tampermonkey**
   - Open Tampermonkey Dashboard
   - For each generated `.js` file:
     - Click "Create a new script"
     - Copy the entire contents of the configured script
     - Paste into the editor
     - Save (Ctrl+S or Cmd+S)

### Manual Setup (Alternative)

If you prefer to configure manually:

1. **Edit Template Files**
   - Open `.template` files in the `TamperMonkey/` directory
   - Replace placeholders:
     - `{{GITLAB_URL}}` → Your GitLab instance URL
     - `{{COMPANY_NAME}}` → Your company name
     - `{{AUTHOR_NAME}}` → Your name
     - `{{STORAGE_KEY_PREFIX}}` → Short prefix for localStorage keys (2-3 lowercase letters)

2. **Save as `.js` files** and install in Tampermonkey as described above

## Configuration

### Environment Variables

All configuration is done through the `.env` file:

- **GITLAB_URL**: Your GitLab instance URL (without `https://`)
  - Example: `gitlab.yourcompany.com`
  
- **COMPANY_NAME**: Your company name (used in script names)
  - Example: `YourCompany`
  
- **AUTHOR_NAME**: Your name (used in `@author` field)
  - Example: `John Doe`
  
- **STORAGE_KEY_PREFIX**: Short prefix for localStorage keys (2-3 lowercase letters)
  - Example: `yc` for "YourCompany"
  - Used to avoid conflicts with other scripts

### ActiTime Script Configuration

After setup, you can still customize the ActiTime script's work schedule by editing the script in Tampermonkey:

```javascript
const HOURS_BY_DAY = {
    0: '8',   // Sunday
    1: '8',   // Monday
    // ... adjust to your work schedule
};
```

## Usage

### GitLab File Tree
- Navigate GitLab repositories with enhanced sidebar
- Use keyboard shortcuts for faster navigation
- Search files quickly within the tree

### GitLab Issue → MR
- Open an issue page
- Click "Create MR" button (added by script)
- Branch name and labels are auto-suggested
- Use keyboard shortcuts for quick actions

### ActiTime AutoFill
- Navigate to your time tracking page
- Press `Ctrl+Alt+F` (or `Cmd+Option+F` on Mac) to auto-fill hours
- View metrics and export data using the script's UI

## Troubleshooting

1. **Scripts not running?**
   - Check Tampermonkey is enabled
   - Verify `@match` URLs match the pages you're visiting
   - Check browser console for errors (F12)

2. **Need to update scripts?**
   - Open Tampermonkey dashboard
   - Edit the script
   - Save changes

3. **Conflicts with other extensions?**
   - Disable conflicting extensions temporarily
   - Check Tampermonkey's script execution order

## Tips

- **Keep scripts updated**: Check for updates regularly
- **Test in development**: Use Tampermonkey's test mode before deploying
- **Backup configurations**: Export scripts from Tampermonkey dashboard
- **Customize for your workflow**: Modify scripts to match your specific needs

## Security Note

⚠️ These scripts have access to web page content. Review the code before installing, especially if obtained from untrusted sources.
