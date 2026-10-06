# Meo Login

Meo Login is the login and display-manager experience shipped by MeoArch. It is maintained as a focused downstream of KDE Plasma Login Manager, which is derived from SDDM. Meo keeps the mature upstream authentication and session backend while providing the Meo login presentation and MeoArch integration.

## Compatibility boundary

The public product name is **Meo Login**.

Internal runtime identifiers such as `plasmalogin`, `/etc/plasmalogin.conf`, PAM service names, translation domains and related systemd units are intentionally retained for upstream compatibility. They are implementation identifiers, not competing product names. Renaming them would create unnecessary PAM, systemd, configuration and upgrade risk.

## Systemd

Systemd is a hard requirement for the current upstream architecture. See the upstream Plasma Login Manager project for its longer-term system design and roadmap.

## Product goals

Meo Login aims to provide:

- a polished out-of-box experience for multi-monitor, high-DPI and HDR systems;
- keyboard-layout switching and virtual-keyboard support;
- practical CJK input support;
- screen-reader and accessible audio support;
- remote-login support where the upstream backend supports it;
- deeper Meo Desktop integration for display and keyboard brightness, power management, trusted Bluetooth devices and known Wi-Fi networks;
- a login presentation consistent with Meo's Material 3 visual and motion language.

## Building for development

This repository tracks the Meo-maintained downstream. Development builds should be tested in a virtual machine before being installed on real hardware because a display-manager failure can prevent graphical login.

On Arch Linux, install `base-devel`, `git`, `cmake` and `extra-cmake-modules`, then build the checkout with the normal CMake flow used by the upstream project.

The release package is built by the MeoArch package pipeline from a pinned, reviewed source revision; end users should install the signed Meo package rather than building the display manager manually.

## Runtime service

The compatibility service name remains `plasmalogin`:

```bash
sudo systemctl disable sddm
sudo systemctl enable plasmalogin
```

This technical service name is expected and does not change the public product name shown by MeoArch.

## Configuration

The frontend currently reads user overrides from `/etc/plasmalogin.conf` and distribution defaults from `/usr/lib/plasmalogin/defaults.conf`. These paths are retained to stay close to upstream and to avoid an unsafe configuration migration during the release train.

Meo-specific presentation and integration changes must stay small enough that security, authentication, session startup and upstream fixes remain reviewable against KDE Plasma Login Manager.

## Upstream and licensing

Meo Login is based on KDE Plasma Login Manager and retains the applicable upstream copyright and license notices. Do not remove upstream attribution when applying Meo branding.