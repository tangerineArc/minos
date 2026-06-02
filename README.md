# Minos

Minos is a **personal** shell/bar built with [AGS](https://github.com/Aylur/ags), GTK4, and Astal. It provides a compact top bar, workspace controls, system indicators, and small quick-settings menus intended for a Niri-based NixOS desktop.

> [!NOTE]
> This is a personal shell and is currently tailored to my setup. You may need to adjust runtime services, battery ID, styling, or widget behavior for your machine.

## Showcase

### Bar

![bar](./showcase/bar.png)

![window-title](./showcase/window-title.png)

### Quick settings

![brightness-controls](./showcase/brightness-controls.png)

![volume-controls](./showcase/volume-controls.png)

### Desktop overview

![full-preview](./showcase/full-preview.png)

## Features

- GTK4/AGS shell for Wayland
- Niri workspace switcher and focused-window display
- System status widgets for:
  - battery
  - Bluetooth
  - brightness
  - volume
  - Wi-Fi
- Quick menus for:
  - brightness and night light
  - power profiles
  - volume and audio devices
- Matugen Integration
- Nix flake package
- Home Manager module with a systemd user service

## Requirements

Minos is designed for a NixOS/Home Manager desktop using:

- Niri
- AGS/Astal
- GTK4
- PipeWire/WirePlumber
- NetworkManager
- Bluetooth, if using the Bluetooth widget
- `power-profiles-daemon`, if using the power profile menu
- `brightnessctl`, if direct backlight writes are not permitted
- `wl-gammarelay-rs`, if using the night-light integration

Some widgets call system tools such as `niri msg`, `brightnessctl`, and `busctl`, so the corresponding services and commands must be available in your session.

## Installation

### As a Home Manager module

Add Minos as an input to your NixOS or Home Manager flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    minos = {
      url = "github:tangerineArc/minos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

Then import the Home Manager module and enable the service:

```nix
{
  inputs,
  ...
}: {
  home-manager.users.your-user = {
    imports = [
      inputs.minos.homeManagerModules.default
    ];

    services.minos.enable = true;
  };
}
```

If you use standalone Home Manager:

```nix
{
  inputs,
  ...
}: {
  imports = [
    inputs.minos.homeManagerModules.default
  ];

  services.minos.enable = true;
}
```

The module installs the package and creates a `minos.service` systemd user service that starts with `graphical-session.target`.

### As a package only

If you only want the package and prefer to manage startup yourself:

```nix
{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.minos.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

Then run:

```sh
minos
```

### Run directly from the flake

```sh
nix run github:tangerineArc/minos
```

### Build locally

Clone the repository and build the package:

```sh
git clone https://github.com/tangerineArc/minos.git
cd minos
nix build
```

Run the built shell:

```sh
./result/bin/minos
```

## Development

Enter the development shell:

```sh
nix develop
```

Run the app during development:

```sh
ags run app.ts
```

Build the packaged app:

```sh
nix build
```

## Configuration

Minos is partly configurable via a standard JSON file and supports real-time hot-reloading for colors and a few layout parameters.

By default, the shell looks for your configuration file at:
`~/.config/minos/config.json`

If the file doesn't exist or a key is missing, Minos automatically falls back to its internal defaults. You only need to define the specific properties you actually want to override.

### Example `config.json`
If your system exposes your battery as `BAT0` instead of `BAT1`, and you want to inject a custom color palette, your config would look like this:
```json
{
  "general": {
    "bar_width": 1000,
    "bar_height": 40,
    "bar_margin_top": 4,
    "default_menu_width": 320,
    "bat_id": "BAT0"
  },
  "colors": {
    "accent-primary": "#c7bfff",
    "bg-1": "#141318",
    "fg-1": "#e5e1e9"
  }
}
```
*(Check `config.ts` for the full list of available color tokens and variables).*

### Dynamic Hot-Reloading
Minos actively monitors `config.json` in the background. Whenever you update your values, the shell will instantly hot-reload the CSS without requiring a session restart.

> [!NOTE]
> **For Vim/Neovim users:** By default, Neovim uses atomic saves (deleting and replacing the file), which will kill the background file watcher. To keep hot-reloading active, ensure `vim.opt.backupcopy = "yes"` is set in your editor config.
