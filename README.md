# Gemini CLI One-Click Setup 🚀

An all-in-one management utility for the **Google Gemini CLI** and its official extensions. This tool automates the installation of Node.js, the core CLI agent, and provides a TUI (Terminal User Interface) to manage extensions.

## 🛠 Features
- **One-Click Core Install**: Automatically handles NodeSource repos and NPM global installs.
- **TUI Menu**: Uses `whiptail` for a clean, Kali-style interface.
- **Extension Library**: Quick access to the most popular extensions from the `gemini-cli-extensions` organization.

## 📦 What's Included?
| Extension | Purpose |
| :--- | :--- |
| **Workspace** | Chat with your Gmail, Calendar, and Google Docs. |
| **Conductor** | High-level planning and code implementation agent. |
| **Security** | Vulnerability scanning for your repos. |
| **Postgres** | Natural language SQL querying. |
| **Firebase** | Backend management and deployment expertise. |

## 🚀 Installation & Usage

### 1. Download the tool
```bash
git clone [https://github.com/D3fc0n3-1/gemini-cli-manager.git](https://github.com/D3fc0n3-1/gemini-cli-manager.git)
cd gemini-cli-manager
chmod +x gemini-setup.sh
```

### 2. Run the Manager
```bash
/gemini-setup.sh
```
Note: If you haven't installed the core CLI yet, select Option 1 first.

### 3. Authenticate
After installing the core, run:
```bash
gemini
```
Follow the browser prompt to log in with your Google account.
