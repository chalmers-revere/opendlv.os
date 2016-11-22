ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master

wget ${ROOT_URL}/arm-bbb/{install,install-conf,install-post}.sh

mkdir setup-root-available
cd setup-root-available
wget ${ROOT_URL}/arm-bbb/setup-root-available/{setup-root-pru.sh,BB-BONE-PRU-00A0.dts}
cd ..

mkdir setup-user-available
cd setup-user-available
wget ${ROOT_URL}/arm-bbb/setup-user-available/setup-user-opendlvclone.sh
cd ..
