#!/bin/bash
echo "--- Setup"
export USE_CCACHE="1"
export CCACHE_EXEC=/usr/bin/ccache
#export PYTHONDONTWRITEBYTECODE=true
#export BUILD_ENFORCE_SELINUX=1
export BUILD_NO=
unset BUILD_NUMBER
#export OVERRIDE_TARGET_FLATTEN_APEX=true 
#TODO(zif): convert this to a runtime check, grep "sse4_2.*popcnt" /proc/cpuinfo
export CPU_SSE42=false
# Following env is set from build
# VERSION
# DEVICE
# TYPE
# RELEASE_TYPE
# EXP_PICK_CHANGES

if [ -z "$BUILD_UUID" ]; then
  export BUILD_UUID=$(uuidgen)
fi

if [ -z "$TYPE" ]; then
  export TYPE=userdebug
fi

#export BUILD_NUMBER=$( (date +%s%N ; echo $BUILD_UUID; hostname) | openssl sha1 | sed -e 's/.*=//g; s/ //g' | cut -c1-10 )

git config --global user.email "temp@example.com"
git config --global user.name "temp"

echo "--- Syncing"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

mkdir lineage
cd lineage/

repo init -u https://github.com/lineageos/android.git -b lineage-17.1

wget https://raw.githubusercontent.com/Gabboxl/local_manifests/master/msm8916_q.xml -P .repo/local_manifests/

echo "Resetting build tree"
repo forall -vc "git reset --hard"
echo "Syncing"
repo sync -j32 -d --force-sync
. build/envsetup.sh


echo "--- clobber"
rm -rf out

echo "--- Building"
brunch lineage_gprimeltexx-userdebug

#echo "--- Uploading"
#ssh jenkins@blob.lineageos.org mkdir -p /home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
#scp out/dist/*target_files*.zip jenkins@blob.lineageos.org:/home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
#scp out/target/product/${DEVICE}/otatools.zip jenkins@blob.lineageos.org:/home/jenkins/incoming/${DEVICE}/${BUILD_UUID}/
