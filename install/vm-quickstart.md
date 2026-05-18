# VM quickstart

Test Journey on a real Arch system without touching your daily-driver box.

## 1. Make the VM

Pick whichever you already have set up. All work fine; just give it ≥4 GB RAM and ≥20 GB disk.

| Tool | Quick start |
|---|---|
| **virt-manager (KVM)** | Open virt-manager → New VM → Local install media → point at Arch ISO. UEFI firmware, virtio everything. |
| **GNOME Boxes** | New → Operating System Install → drop the Arch ISO. Defaults are fine. |
| **VirtualBox** | New → Linux / Arch (64-bit). Mount the ISO under Settings → Storage. |
| **QEMU one-liner** | `qemu-system-x86_64 -enable-kvm -m 4G -cdrom archlinux.iso -drive file=arch.qcow2,format=qcow2 -smp 4 -vga virtio` |

Download the ISO from [archlinux.org/download](https://archlinux.org/download/).

## 2. Install Arch (the minimal path)

Follow the [Arch install guide](https://wiki.archlinux.org/title/Installation_guide), or use the `archinstall` TUI bundled in the ISO:

```bash
# Booted to the ISO root shell
archinstall
```

Pick:
- **Profile**: Minimal
- **Bootloader**: systemd-boot (or limine if you want to match Journey's default)
- **Hyprland**: don't pick this — Journey will install it
- **User**: create a regular user (e.g. `you`), add to `wheel`, enable sudo

After install finishes, reboot, log in as your user.

## 3. Get Journey onto the VM

Pick whichever's easiest for your setup:

### (a) Tarball over SSH

On this (Omarchy) box:
```bash
journey-bundle --output ~/journey.tar.gz
scp ~/journey.tar.gz you@<vm-ip>:~/
```

On the VM:
```bash
sudo pacman -S --needed --noconfirm tar
tar -xzf journey.tar.gz
cd journey
```

### (b) rsync directly

```bash
# from this box
rsync -av /home/djcoffey/Projects/Journey/ you@<vm-ip>:~/journey/
```

### (c) Push to GitHub, clone on the VM

```bash
# on the VM
sudo pacman -S --needed --noconfirm git
git clone https://github.com/DanielCoffey1/Journey.git journey
cd journey
```

### (d) Shared folder

If virt-manager / Boxes / VirtualBox has shared folders set up, just point the VM at `/home/djcoffey/Projects/Journey/`.

## 4. Run the installer

```bash
cd journey
./install.sh
```

What this does (~5-15 min depending on network):
1. Installs ~225 packages via pacman (and yay for AUR bits — `walker-bin`)
2. Stows configs into `~/.config/`
3. Sets `tokyo-night` as the active theme
4. Enables NetworkManager, bluetooth, docker, cups, sddm

When it finishes, reboot:

```bash
sudo reboot
```

## 5. Exercise the desktop

Log in via SDDM, pick Hyprland (Journey-default session). Then walk through:

| Test | What you should see |
|---|---|
| `SUPER+SPACE` | Walker opens, branded "Journey Companion", search Arch apps |
| `SUPER+ALT+SPACE` | Root Journey menu — pick "System", confirm lock/suspend/etc work |
| `SUPER+K` | Searchable keybind list (192 binds) |
| `SUPER+SHIFT+CTRL+SPACE` | Theme picker → switch to gruvbox → everything recolours (walker, waybar, mako, terminals, btop) |
| `SUPER+CTRL+SPACE` | Background picker (empty for shipped themes; drop a `.jpg` into `~/.local/share/journey/themes/<name>/backgrounds/` then retry) |
| `SUPER+RETURN` | Terminal opens in your cwd |
| `SUPER+SHIFT+B` | Default browser (chromium) launches |
| `PRINT` | Region screenshot + satty annotation → file saved + copied to clipboard |
| `XF86AudioRaiseVolume` (laptop) | OSD popup, volume rises |
| `SUPER+CTRL+L` | hyprlock screen, themed |

Run a CLI sanity sweep too:
```bash
journey help               # listing of all 76 commands
journey theme list         # 19 themes
journey theme set nord     # active theme changes, everything reloads
journey-update --check     # shows what a real update would touch
journey-uninstall --keep-configs  # cleans Journey out, keeps the stowed configs
```

## 6. Snapshot it

Once you have a known-good install, take a VM snapshot — that's your golden baseline for regression-testing future Journey changes.
