#!/bin/bash

cd

source install-conf.sh

# Post install
pacman -Syy

echo "Setup hostname & timezone"
echo "Set hostname ($hostname)"
echo $hostname > /etc/hostname
echo "Set local timezone ($timezone)"
ln -fs /usr/share/zoneinfo/$timezone /etc/localtime

echo "Uncomment locales"
for i in ${locale[@]}; do
    echo "Add locale $i"
    sed -i "s/^#$i/$i/g" /etc/locale.gen
done
echo "Generate locales"
locale-gen
echo "Set up default locale (${locale[0]})"
echo "LANG=${locale[0]}" > /etc/locale.conf

echo "Set font as $font and keymap as $keymap"
echo "KEYMAP=$keymap" > /etc/vconsole.conf
echo "FONT=$font" >> /etc/vconsole.conf

echo "Install software"
for (( i = 0; i < ${#software[@]}; i++ )); do
    echo "Install software ($((i+1))/${#software[@]})"
    pacman -S --noconfirm ${software[$i]}
done

echo "Clean mess - remove orphans recursively"
orphans=`pacman -Qtdq`
if [ ! "$orphans" == "" ]; then
  pacman -Rns $orphans --noconfirm || true
fi

if [ ! "$service" == "" ]; then
    echo "Enable services"
    for s in ${service[@]}; do
        echo "Enable $s service"
        systemctl enable $s
    done
fi

if [ ! "$group" == "" ]; then
    echo "Create non-existing groups"
    for i in "${group[@]}"; do
        IFS=',' read -a grs <<< "$i"
        for j in "${grs[@]}"; do
            if [ "$(grep $j /etc/group)" == "" ]; then
                echo "Add group '$j'"
                groupadd $j
            fi
        done
    done
fi

echo "Setup users"
for (( i = 0; i < ${#user[@]}; i++ )); do
    useradd -m -g users -s /bin/bash ${user[$i]}
    if [ ! "${group[$i]}" == "" ]; then
        echo "Add user ${user[$i]} to groups: '${group[$i]}'"
        usermod -G ${group[$i]} ${user[$i]}
    fi

    echo "Place user-defined script in home directory"
    cd /home/${user[$i]}
    cp /root/setup-${user[$i]}.sh user.sh
    echo "Make executable (+x)"
    chmod +x user.sh
    echo "Execute user-defined script by ${user[$i]} user"
    mv .bash_profile .bash_profilecopy 2>/dev/null
    su -c ./user.sh -s /bin/bash ${user[$i]}
    mv .bash_profilecopy .bash_profile 2>/dev/null
    echo "Remove user.sh scripts from home directory"
    rm user.sh
    cd

    if [ ! "${shell[$i]}" == "" ]; then
        echo "Set ${user[$i]} shell to ${shell[$i]}"
        chsh -s ${shell[$i]} ${user[$i]}
    fi
done

echo "Execute root script"
chmod +x setup-root.sh
/bin/bash setup-root.sh

echo "Setup all passwords"
echo "Setup ROOT password"
passwd
for i in ${user[@]}; do
    echo "Setup user ($i) password"
    passwd $i
done

echo "Finish installation"
exit
