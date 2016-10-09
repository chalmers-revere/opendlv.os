ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master

wget ${ROOT_URL}/x86/{install,install-conf,install-post}.sh

mkdir setup-root-available
cd setup-root-available
wget ${ROOT_URL}/x86/setup-root-available/setup-root-{4g,desktop,router,wifi}.sh
cd ..

mkdir setup-user-available
cd setup-user-available
wget ${ROOT_URL}/x86/setup-user-available/setup-user-opendlvclone.sh
cd ..
