#!/bin/bash -x
Rebuild_SRPM() {
local SRPM_PATH_DIR=/root/rpmbuild/SRPMS
local SPEC_PATH_DIR=/root/rpmbuild/SPECS
local SRPM_Package_Name=$1
local SPEC_Name=`echo $SRPM_Package_Name|sed 's/.\$SRPM_Release.src.rpm$//g'|sed 's/-[0-9]//g'|cut -d'.' -f1`
local RPM_PATH_DIR=/root/rpmbuild/RPMS
rpm -ivh $SRPM_PATH_DIR/$SRPM_Package_Name
rpmbuild -bb $SPEC_PATH_DIR/$SPEC_Name.spec
lcoal RETURN=$?
if [ $RETURN == 0 ]
	echo -e "Sir! You have build Package from $SRPM_Package_Name sucessfully!\n"
	if [ -f "$RPM_PATH_DIR/noarch/$SPEC_Name-[0-9]*.rpm" ]
		then	
		local RPM_PATH_DIR=/root/rpmbuild/RPMS/noarch
	elif [ -f "$RPM_PATH_DIR/x86_64/$SPEC_Name-[0-9]*.rpm" ]
		then
		local RPM_PATH_DIR=/root/rpmbuild/RPMS/x86_64
	else
		local RPM_PATH_DIR=/root/rpmbuild/RPMS/i686
	fi
	local RPM_Package_Name=`basename $RPM_PATH_DIR/$SPEC_Name-[0-9]*.rpm`
	then Install_RPM "$RPM_Package_Name";
else
	SRPM_DEP "$SRPM_Package_Name";	
fi
}

SRPM_DEP() {
local SRPM_PATH_DIR=/root/rpmbuild/SRPMS
local SPEC_PATH_DIR=/root/rpmbuild/SPECS
local SRPM_Package_Name=$1
local SPEC_Name=`echo $SRPM_Package_Name|sed 's/.\$SRPM_Release.src.rpm$//g'|sed 's/-[0-9]//g'|cut -d'.' -f1`
rpm -ivh $SRPM_PATH_DIR/$SRPM_Package_Name
local TMP_DIR=`mktemp`/SRPM
rpmbuild -bb $SPEC_PATH_DIR/$SPEC_Name.spec > $TMP_DIR/$SRPM_Package_Name 2>&1
cat $TMP_DIR/$SRPM_Package_Name |grep "needed\ by" |cut -d')' -f1|cut -d'(' -f2|sed 's/\:\:/-/g'|sed 's/^/perl-/g' > $TMP_DIR/$SRPM_Package_Name.NeedPackages.swap
local NEED_SRPM_COUNT=`cat $TMP_DIR/$SRPM_Package_Name.NeedPackages.swap |wc -l`
for ((i=0;i<$NEED_SRPM_COUNT;i++));do
	for NEED_SRPM in `cat $TMP_DIR/$SRPM_Package_Name.NeedPackages.swap`;do
		local NEED_SRPM=`base $SRPM_PATH_DIR/$NEED_SRPM-[0-9]*.rpm`	
		Rebuild_SRPM "NEED_SRPM"
	done
done
}

Install_RPM() {
local RPM_PATH_DIR=/root/rpmbuild/RPMS
local RPM_Package_Name=$1
if [ -f "$RPM_PATH_DIR/noarch/$SPEC_Name-[0-9]*.rpm" ]
	then	
	local RPM_PATH_DIR=/root/rpmbuild/RPMS/noarch
elif [ -f "$RPM_PATH_DIR/x86_64/$SPEC_Name-[0-9]*.rpm" ]
	then
	local RPM_PATH_DIR=/root/rpmbuild/RPMS/x86_64
else
	local RPM_PATH_DIR=/root/rpmbuild/RPMS/i686
fi
echo -e "Sir! I am trying to install the $RPM_Package_Name Package!\n"
rpm -ivh --force "$RPM_PATH_DIR/$RPM_Package_Name";
local RETUEN=$?
if [ $RETURN == 0 ]
	then
	echo -e "Sir! The $RPM_Package_Name Package has been installed sucessfully!\n"
else
	RPM_DEP "$RPM_Package_Name";	
fi
}

RPM_DEP() {
TMP_DIR=`mktemp`/RPM
local RPM_PATH_DIR=/root/rpmbuild/RPMS
local RPM_Package_Name=$1
if [ -f "$RPM_PATH_DIR/noarch/$SPEC_Name-[0-9]*.rpm" ]
	then	
	local RPM_PATH_DIR=/root/rpmbuild/RPMS/noarch
elif [ -f "$RPM_PATH_DIR/x86_64/$SPEC_Name-[0-9]*.rpm" ]
	then
	local RPM_PATH_DIR=/root/rpmbuild/RPMS/x86_64
else
	local RPM_PATH_DIR=/root/rpmbuild/RPMS/i686
fi
rpm -ivh --force "$RPM_PATH_DIR/$RPM_Package_Name" > $TMPDIR/$RPM_Package_Name 2>&1;
NEED_RPM_COUNT=`cat $TMPDIR/$RPM_Package_Name |grep "needed\ by"|wc -l`
for ((i=0;i<$NEED_RPM_COUNT;i++)) ;do
	for NEED_RPM in `cat $TMPDIR/$RPM_Packae_Name`;do
	yum -y install $NEED_RPM	
	done
done

}


if [ `rpm -qa |grep rpmbuild|wc -l` == 0 ]
	then yum install -y rpmbuild
else	
	echo -e "Sir! You can use rpmbuild to work now!\n"
fi
SRPM_Release=fc17
Rebuild_SRPM "$1";
exit 0;
