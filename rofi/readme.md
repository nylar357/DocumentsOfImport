# Custom Rofi Widgets Collection

A collection of lightweight, bash-driven [Rofi](https://github.com/davatorium/rofi) scripts and widgets designed to streamline Linux desktop workflows. These tools provide quick, keyboard-centric ways to manage system power, edit configurations, and launch applications without relying on heavy GUI programs.

## 📦 Dependencies

Depending on which scripts you use, you will need the following installed on your system:

* **Core:** `rofi` (Version 1.7.0+ recommended for background image support)
* **Power Widget:** `power-profiles-daemon` (`powerprofilesctl`), `notify-send`
* **Dotfile Editor:** `ripgrep` (`rg`), `kitty`, `neovim` (`nvim`)
* **Fonts:** A Nerd Font (e.g., *GohuFont Nerd Font*, *Liquid Crystal*)

---

## 🛠️ The Widgets

### 1. Power Profile Manager (`power.sh`)
A highly customized Rofi HUD to manage your system's power states on the fly. Designed with a Dracula/Nord-inspired theme, transparent overlays, and background image scaling.

**Key Features:**
* **Instant Toggling:** Switch between `Performance`, `Balanced`, and `Power Saver` modes via `powerprofilesctl`.
* **Hardware Polling:** Dynamically queries the Linux kernel's scaling governor (`cpufreq`) to display your live minimum and maximum CPU frequencies.
* **Thermal Monitoring:** Hooks into the `k10temp` module (with thermal zone fallbacks) to display live CPU die temperatures.
* **UI/UX:** Features a toggle-logic launch (running the script while Rofi is open will close it) and sends desktop notifications upon profile switching.

### 2. Quick Dotfile Editor (`edit_dotfiles.sh`)
A lightning-fast file searcher specifically tailored for editing configuration files in your `~/.config` directory.

**Key Features:**
* **Fuzzy Searching:** Uses `ripgrep` to rapidly index your `~/.config` directory.
* **Smart Filtering:** Automatically ignores heavy cache or state directories (like `chromium`, `firefox`, and `mpv/watch_later`) using a temporary ignore file.
* **Terminal Integration:** Immediately opens the selected configuration file in `neovim` via the `kitty` terminal emulator. 

### 3. App Launcher Toggle (`launcher.sh`)
A simple, elegant wrapper for Rofi's application launcher (`drun` mode).

**Key Features:**
* **Toggle Behavior:** Acts as a toggle switch. If Rofi is already running, executing the script kills it. If closed, it opens it. Perfect for binding to a single hotkey (like `Super`).
* **Custom Config & Font:** Forces specific font rendering (GohuFont Nerd Font) and loads your global Rofi configuration directly.

---

## 🚀 Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/rofi-widgets.git
   cd rofi-widgets
   ```

2. **Make the scripts executable:**
   ```bash
   chmod +x *.sh
   ```

3. **Configure Paths:**
   * Open the scripts and ensure the hardcoded paths match your system setup. 
   * Specifically, update the `background-image: url("/home/polyz/nord_roads2.png", height);` path in the Power Profile widget, and the `dir="/home/polyz/.config"` path in the Dotfile Editor.

4. **Bind to Hotkeys:**
   Map the scripts to your preferred keyboard shortcuts using your window manager's configuration file (e.g., `hyprland.conf`, `sxhkdrc`, or `i3/config`).

   *Example (Hyprland):*
   ```ini
   bind = $mainMod, P, exec, /path/to/power.sh
   bind = $mainMod, E, exec, /path/to/edit_dotfiles.sh
   bind = $mainMod, Space, exec, /path/to/launcher.sh
   ```

## 🤝 Contributing
Feel free to fork this repository, submit pull requests, or open issues if you have ideas for new features or encounter any bugs!