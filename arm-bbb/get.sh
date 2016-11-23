if [ "$1" == "" ]; then
  $1 = "master"
fi

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/${1}

wget ${ROOT_URL}/arm-bbb/{install,install-conf,install-env,install-post}.sh

mkdir setup-root-available
cd setup-root-available
wget ${ROOT_URL}/arm-bbb/setup-root-available/setup-env-root-pru.sh ${ROOT_URL}/arm-bbb/setup-root-available/setup-post-root-pru.sh ${ROOT_URL}/arm-bbb/setup-root-available/setup-post-root-docker.sh

cd ..

mkdir setup-user-available
cd setup-user-available
wget ${ROOT_URL}/arm-bbb/setup-user-available/setup-post-user-opendlvclone.sh
cd ..
