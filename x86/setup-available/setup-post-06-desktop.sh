#!/bin/bash

gfx="nvidia"

pacman -S --noconfirm eog evince firefox gdm gedit gnome-system-monitor gnome-terminal gvim ${gfx}
systemctl enable gdm
