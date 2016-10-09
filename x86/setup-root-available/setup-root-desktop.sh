software="nvidia"

pacman -S --noconfirm eog evince firefox gdm gedit gnome-system-monitor gnome-terminal gvim ${software}
systemctl enable gdm
