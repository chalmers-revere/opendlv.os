#!/bin/bash

WORKDIR=/tmp/kernel_build

KERNEL_BASE_URL="https://mirrors.edge.kernel.org/pub/linux/kernel"
RT_BASE_URL="https://www.kernel.org/pub/linux/kernel/projects/rt"

CONFIG_URL=https://git.archlinux.org/svntogit/packages.git/plain/trunk/config?h=packages/linux

KERNEL_OPTIONS_Y=( CONFIG_RT_GROUP_SCHED )


rt_version_list=`wget -q $RT_BASE_URL -O - | grep '^<a href'`
latest_version='';
latest_date=`date -d 1970-01-01 +%s`
while read -r line; do
  version=`echo $line | cut -d '"' -f2 | cut -d '/' -f1 | grep [0-9]`
  date_text=`echo $line | cut -d '>' -f3 | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f1`
  date=`date -d $date_text +%s`

  if [ $date -ge $latest_date ]
  then
    latest_version=$version;
    latest_date=$date;
  fi
done <<< "$rt_version_list"

echo "Latest detected Linux RT patch version: $latest_version"

rt_patch_filename=`wget -q $RT_BASE_URL/$latest_version -O - | grep 'patch.xz' | cut -d '"' -f2`

kernel_major=`echo $latest_version | cut -d '.' -f1`

kernel_url=$KERNEL_BASE_URL/v$kernel_major.x/linux-$latest_version.tar.xz
rt_patch_url=$RT_BASE_URL/$latest_version/$rt_patch_filename

file=`echo "${kernel_url##*/}"`
folder=`echo $file | cut -d '.' -f1-2`

mkdir -p ${WORKDIR}
cp *.patch ${WORKDIR}
cd ${WORKDIR}

wget -N ${kernel_url}
tar -xf ${file}

cd ${folder}

wget -N ${rt_patch_url}
wget -N ${CONFIG_URL} -O .config

echo -e "Applying RT patch\n"
xzcat $rt_patch_filename | patch -p1

echo -e "Applying additional patches\n"
for f in ../*.patch; do
  echo " .. patch: $f"
  patch -p1 -i $f
done

make defconfig

echo -e "Configuring\n"
for (( i = 0; i < ${#KERNEL_OPTIONS_Y[@]}; i++ )); do
  sed -i "s/.*${KERNEL_OPTIONS_Y[$i]}.*/${KERNEL_OPTIONS_Y[$i]}=y/" .config
  echo -e " .. setting: ${KERNEL_OPTIONS_Y[$i]}=y\n"
done

make -j4
