#!/bin/bash

echo "Generating get.sh for ${1}..."

setup_list=
cd ${1}/setup-available
for f in setup-*.sh; do
  setup_list=${setup_list}' ${ROOT_URL}/setup-available/'${f}
done
cd ../..

echo '#!/bin/bash

if [ "${1}" == "" ]; then
  ${1} = "master"
fi

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/${1}/'${1}'

wget ${ROOT_URL}/{install,install-conf,install-sys,install-post}.sh

mkdir setup-available
cd setup-available
wget '${setup_list} > ${1}/get.sh

echo "Done."
