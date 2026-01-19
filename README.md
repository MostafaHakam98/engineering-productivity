# Engineering Productivity

A practical, version-controlled collection of workflows, automations, and tools that reduce friction in daily engineering work. This repository treats productivity as a system: browser-level automation, editor-level refactors, shell workflows, and knowledge shared as code — all designed to be reviewable, reproducible, and installable.

## 📚 Overview

This repository organizes productivity tools and knowledge into modular, installable components grouped by domain. Each directory contains:
- **Markdown documentation** explaining the knowledge and workflows
- **Installation scripts** or instructions for easy setup
- **Ready-to-use** configurations and scripts

## 🗂️ Structure

The repository is organized by domain:

```
engineering-productivity/
├── shell/          # Shell and terminal tools
│   ├── aliases/    # Bash aliases & configuration
│   └── terminal/   # Terminal multiplexing (screen/tmux)
├── git/            # Git tools
│   └── hooks/      # Pre-commit & pre-push hooks
├── browser/        # Browser tools and shortcuts
│   ├── scripts/    # TamperMonkey automation scripts
│   └── shortcuts/  # Browser keyboard shortcuts
├── editor/         # Editor tips and shortcuts
│   └── vscode/     # Visual Studio Code
└── os/             # Operating system shortcuts
    └── ubuntu/     # Ubuntu/GNOME
```

## 🗂️ Components

### [shell/](./shell/) - Shell & Terminal Tools

#### [shell/aliases](./shell/aliases/) - Bash Aliases & Shell Configuration
Modular bash aliases for Git, Docker, navigation, and more. Organized by category with numbered load order.

**Installation:**
```bash
cd shell/aliases
./setup.sh
```

**Documentation:** [shell/aliases/README.md](./shell/aliases/README.md)

#### [shell/terminal](./shell/terminal/) - Terminal Session Management
Quick reference for terminal multiplexers (`screen` and `tmux`).

**Installation:** No installation needed — reference documentation

**Documentation:**
- [shell/terminal/README.md](./shell/terminal/README.md)
- [shell/terminal/CheatSheet.md](./shell/terminal/CheatSheet.md)

---

### [git/](./git/) - Git Tools

#### [git/hooks](./git/hooks/) - Pre-commit & Pre-push Hooks
Git hooks that enforce code quality and prevent common mistakes (TODO/FIXME, debug prints, secrets).

**Installation:**
```bash
cd git/hooks
./setup.sh
# Or specify a repository: ./setup.sh /path/to/repo
```

**Documentation:** [git/hooks/README.md](./git/hooks/README.md)

---

### [browser/](./browser/) - Browser Tools

#### [browser/scripts](./browser/scripts/) - TamperMonkey Automation Scripts
UserScripts for GitLab and ActiTIME that enhance productivity with keyboard shortcuts and automation.

**Installation:**
1. Configure `.env` file (copy from `.env.example` and fill in your values)
2. Run setup script: `cd browser/scripts && ./setup.sh`
3. Install [Tampermonkey](https://www.tampermonkey.net/) browser extension
4. Install configured scripts from generated `.js` files

**Documentation:** [browser/scripts/README.md](./browser/scripts/README.md)

**Scripts:**
- `GitLab-File-Tree.js` - Enhanced GitLab file tree sidebar
- `GitLab-Issue-MR.js` - Issue to MR helper with auto-suggestions
- `ActiTime-AutoFill.js` - Time tracking automation

#### [browser/shortcuts](./browser/shortcuts/) - Browser Keyboard Shortcuts
Keyboard shortcuts and workflows for efficient browser usage (Chrome-focused).

**Installation:** No installation needed — reference documentation

**Documentation:**
- [browser/shortcuts/README.md](./browser/shortcuts/README.md)
- [browser/shortcuts/ChromeShortcuts.md](./browser/shortcuts/ChromeShortcuts.md)

---

### [editor/](./editor/) - Editor Tools

#### [editor/vscode](./editor/vscode/) - Visual Studio Code
Productivity tips and keyboard shortcuts for VSCode.

**Installation:** No installation needed — reference documentation

**Documentation:**
- [editor/vscode/README.md](./editor/vscode/README.md)
- [editor/vscode/VSCode.md](./editor/vscode/VSCode.md)

---

### [os/](./os/) - Operating System Tools

#### [os/ubuntu](./os/ubuntu/) - Ubuntu/GNOME
OS-level keyboard shortcuts and commands for efficient system navigation.

**Installation:** No installation needed — reference documentation

**Documentation:**
- [os/ubuntu/README.md](./os/ubuntu/README.md)
- [os/ubuntu/Ubuntu.md](./os/ubuntu/Ubuntu.md)

---

## 🚀 Quick Start

1. **Clone this repository:**
   ```bash
   git clone <repo-url>
   cd engineering-productivity
   ```

2. **Install components you need:**
   ```bash
   # Bash aliases (recommended)
   cd shell/aliases && ./setup.sh
   
   # Git hooks (for your repositories)
   cd git/hooks && ./setup.sh /path/to/your/repo
   
   # Browser scripts (configure .env first)
   cp .env.example .env
   # Edit .env with your values
   cd browser/scripts && ./setup.sh
   ```

3. **Read the documentation:**
   - Each directory has a `README.md` with detailed information
   - Markdown files contain specific knowledge and shortcuts

## 📖 Philosophy

This repository follows these principles:

- **Modular**: Each component is independent and can be used separately
- **Documented**: Every component has clear documentation
- **Installable**: Automated setup scripts where possible
- **Version-controlled**: Track changes and share improvements
- **Keyboard-first**: Minimize mouse usage, maximize efficiency
- **Context-aware**: Organize by workspace, not by application
- **Domain-organized**: Grouped by functional area for easy navigation

## 🔧 Customization

All components are designed to be customized:

- **Aliases**: Edit `.sh` files to match your workflow
- **Git Hooks**: Modify regex patterns and checks
- **Browser Scripts**: Configure via `.env` file
- **Documentation**: Add your own tips and shortcuts

## 🤝 Contributing

Feel free to:
- Add new components
- Improve existing documentation
- Share your own productivity workflows
- Fix issues and suggest improvements

## 📝 License

This is a personal productivity repository. Use and modify as needed for your own workflows.

---

> **Remember**: Productivity tools are only effective if they reduce friction. If something doesn't work for you, customize it or remove it.
