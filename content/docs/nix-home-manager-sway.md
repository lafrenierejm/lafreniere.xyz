---
title: "Sway on NixOS via Home Manager"
date: 2024-08-24T14:35:00-04:00
draft: false
---

NixOS has very good support and documentation for system-wide installations of the [Sway](https://swaywm.org/) Wayland compositor.
However, I prefer to manage any user-specific setup via [Home Manager](https://nix-community.github.io/home-manager/) rather than the system configuration whenever possible.
I found the available resources for running Sway via Home Manager to be slightly unclear and/or incomplete;
this post is my attempt to consolidate and explain my setup.

## Why use Home Manager for Sway?

In general, using Home Manager for user-specific configurations has a number of benefits related to security, resource utilization, etc.
Most of those benefits are only theoretical at the tiny scale at which I deploy NixOS.
However, I _do_ benefit in a real way from Home Manager's implicit enforcement of separation of concerns between machine- and user-level configurations.

## System-Level Configurations

I personally isolate the system-level configuration that is specific to Sway to a single file.
This allows me to just import that file on any machine that I wish to have a graphical interface.
The full code file can be found in my dotfiles repo as [`/nix/linux/graphical.nix`](https://git.sr.ht/~lafrenierejm/dotfiles/tree/main/nix/linux/graphical.nix):

```nix
{pkgs, ...}: rec {
  programs.dconf.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    grim
    mako
    slurp
    sway
    wl-clipboard
  ];

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  users.users.greeter = {};
}
```

### Login Manager

[greetd](https://sr.ht/~kennylevinsen/greetd/) is my preferred login manager.
The project's homepage describes it as "a minimal and flexible login manager daemon that makes no assumptions about what you want to launch."
I also use [tuigreet](https://github.com/apognu/tuigreet) a simple, lightweight console frontend for greetd.

Since the login manager is what actually launches your Wayland compositor, it is easiest to include its declaration in your system config rather than in the user-specific Home Manager config.
Note that this requires the `sway` command be globally available, so be sure to include the package in your `environment.systemPackages`.

### Polkit

Sway's wiki briefly describes the use of polkit in the section ["Wayland won't let me run apps as root"](https://github.com/swaywm/sway/wiki/Home/d6f321ff6f6ffe31b7943757ade5da531b9e2bd3#wayland-wont-let-me-run-apps-as-root):

> Generally speaking, running graphical applications as root is discouraged.
> Modern Linux distributions usually ship with a configured Polkit system which allows applications to request permissions for specific administrative actions as needed.

In NixOS 24.05, polkit is exposed as a direct child of the `security` attribute.
Simply enable it in your system configuration as `security.polkit.enable = true`.

### Keyring

Notably, gnome-keyring needs to be run as a system-level service (i.e. `services.gnome.gnome-keyring`) and _not_ as a user-level service.
If gnome-keyring is run as a user-level service, other daemons such as Network Manager will be unable to cache secrets (at least not without specialized configuration that I couldn't figure out).

## User-Level Configuration

The following is the content of my dotfiles file [`/nix/home/sway.nix`](https://git.sr.ht/~lafrenierejm/dotfiles/tree/main/nix/home/sway.nix) as of commit [13552a7](https://git.sr.ht/~lafrenierejm/dotfiles/commit/13552a761ec206cc229e4a814b5477a8e0d9a348).

```nix
{
  pkgs,
  lib,
  ...
}: let
  mod = "Mod4";
in {
  programs.wofi = {
    enable = true;
    settings = {
      allow_markup = true;
      width = 250;
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      keybindings = lib.attrsets.mergeAttrsList [
        (lib.attrsets.mergeAttrsList (map (num: let
          ws = toString num;
        in {
          "${mod}+${ws}" = "workspace ${ws}";
          "${mod}+Ctrl+${ws}" = "move container to workspace ${ws}";
        }) [1 2 3 4 5 6 7 8 9 0]))

        (lib.attrsets.concatMapAttrs (key: direction: {
            "${mod}+${key}" = "focus ${direction}";
            "${mod}+Ctrl+${key}" = "move ${direction}";
          }) {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
          })

        {
          "${mod}+Return" = "exec --no-startup-id ${pkgs.kitty}/bin/kitty";
          "${mod}+space" = "exec --no-startup-id wofi --show drun,run";

          "${mod}+x" = "kill";

          "${mod}+a" = "focus parent";
          "${mod}+e" = "layout toggle split";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+g" = "split h";
          "${mod}+s" = "layout stacking";
          "${mod}+v" = "split v";
          "${mod}+w" = "layout tabbed";

          "${mod}+Shift+r" = "exec swaymsg reload";
          "--release Print" = "exec --no-startup-id ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          "${mod}+Ctrl+l" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
          "${mod}+Ctrl+q" = "exit";
        }
      ];
      focus.followMouse = false;
      startup = [
        {command = "firefox";}
      ];
      workspaceAutoBackAndForth = true;
    };
    systemd.enable = true;
    wrapperFeatures = {gtk = true;};
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  home.file.".hm-graphical-session".text = pkgs.lib.concatStringsSep "\n" [
    "export MOZ_ENABLE_WAYLAND=1"
    "export NIXOS_OZONE_WL=1" # Electron
  ];

  services.cliphist.enable = true;

  services.kanshi = {
    enable = true;

    profiles = {
      home_office = {
        outputs = [
          {
            criteria = "DP-2";
            scale = 2.0;
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "DP-1";
            scale = 2.0;
            status = "enable";
            position = "1920,0";
          }
          {
            criteria = "DP-3";
            scale = 2.0;
            status = "enable";
            position = "3840,0";
          }
        ];
      };
    };
  };

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    mako # notifications
  ];
}
```
