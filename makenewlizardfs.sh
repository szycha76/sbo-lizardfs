#!/bin/bash

startdir=$(pwd)
set -e
wd=$(mktemp -d)
mkdir -pv $wd/lizardfs
list=$(cat  << EOL
slack-desc
doinst.sh
README
lizardfs.SlackBuild
lizardfs.info
setup.lizardfs-services.new
rc.lizardfs-cgiserv.new
rc.lizardfs-chunkserver.new
rc.lizardfs-master.new
rc.lizardfs-metalogger.new
rc.lizardfs.new
EOL
)
echo "$list" | xargs cp -a --target-dir=$wd/lizardfs -v
cd $wd

NEWVERSION=${NEWVERSION:-3.12.0}

PKGTYPE=${PKGTYPE:-txz}
slackver=${slackver:-14.2}
sbourl=${sbopkg:-https://www.slackbuilds.org/slackbuilds}

export LINUXPATH PKGTYPE

for sbo in lizardfs; do
	#curl -# --insecure $sbourl/$slackver/system/$sbo.tar.gz > $sbo.tar.gz && tar xf $sbo.tar.gz || echo no $sbo.tar.gz found
	(
		cd $sbo
		VERSION=$(grep ^VERSION= $sbo.info|cut -d'"' -f2|sed 's:\.:\\.:g')
		sed -i.old s/$VERSION/$NEWVERSION/g $sbo.info $sbo.SlackBuild
		srcurl=$(grep DOWNLOAD= $sbo.info|cut -d'"' -f2)
		wget --no-check-certificate "$srcurl"
		MD5SUM=$(md5sum *.gz |cut -d' ' -f1)
		sed -i.old.md5 "s/^MD5SUM=.*$/MD5SUM=\"$MD5SUM\"/" $sbo.info
		#tar xf *.gz
		./$sbo.SlackBuild
		#installpkg /tmp/$sbo-*_SBo.$PKGTYPE
	)
	#tar tf $sbo.tar.gz|grep -v /$|tar cvvf - -T -|gzip -9 > /tmp/$sbo.tar.gz
	cd "$startdir"
	echo "$list"|tar cvvf - -T -|gzip -9 > /tmp/$sbo.tar.gz
done

rm -rf $wd /tmp/SBo
