# IntuneWinAppUtil GUI Wrapper

A simple PowerShell WPF GUI to streamline packaging apps into the `.intunewin` format using Microsoft's `IntuneWinAppUtil.exe`. It only really saves 5-10 seconds of copying paths but the little things like these matter!

## 🚀 Features

- **Drag and Drop Interface**: Easily drop your source folder into the GUI.
- **Smart Defaults**: Preconfigured for PSADT v4 apps — no need to manually enter repeated values.
- **Auto Renaming**: The generated `.intunewin` file is renamed to match your source folder.
- **Output to Current Directory**: Keeps things clean and easy to find.
- **No Setup Required**: Just place this script in the same directory as `IntuneWinAppUtil.exe`.

## 🔧 Requirements

- PowerShell 5.1 or later
- `IntuneWinAppUtil.exe` must be in the same folder as this script

## 📦 Planned Features

- Bulk packaging support
- Microsoft Graph API integration
- One-click deployment to Intune

## 📝 Usage

1. Place `IntuneWinAppUtil.exe` and this `.ps1` script in the same folder.
2. Run the script (`Right-click → Run with PowerShell`).
3. Enjoy!

---

**Made to scratch my own itch and help out users who aren't as comfortable or slower using CLI**
