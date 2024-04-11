#!/bin/sh

ANYCONNECT_INSTPREFIX="/opt/cisco/anyconnect"
ANYCONNECT_BINDIR="${ANYCONNECT_INSTPREFIX}/bin"
ANYCONNECT_LIBDIR="${ANYCONNECT_INSTPREFIX}/lib"
ANYCONNECT_PLUGINDIR="${ANYCONNECT_BINDIR}/plugins"
ISEPOSTURE_PROFILEDIR="${ANYCONNECT_INSTPREFIX}/iseposture"
ISEPOSTURE_SCRIPTDIR="${ISEPOSTURE_PROFILEDIR}/scripts"

LOGDIR="/var/log/anyconnect"
LOG="${LOGDIR}/iseposture-uninstall.log"

ANYCONNECT_ISE_POSTURE_PACKAGE_ID=com.cisco.pkg.anyconnect.iseposture

LAUNCHD_FILE="/Library/LaunchAgents/com.cisco.anyconnect.aciseposture.plist"
ISEBINFILES="aciseposture aciseagentd iseposture_uninstall.sh manifesttool_iseposture" 
ISELIBFILES="libacise.dylib"
ISEPLUGINFILES="libaciseshim.dylib libacisectrl.dylib"

# Create log directory if not exist
if [ ! -d ${LOGDIR} ]; then
  mkdir -p ${LOGDIR} >/dev/null 2>&1
fi

echo "Uninstalling Cisco AnyConnect ISE Posture Module..."
echo "Uninstalling Cisco AnyConnect ISE Posture Module..." > "${LOG}"
echo `whoami` "invoked $0 from " `pwd` " at " `date` >> "${LOG}"

# Check for root privileges
if [ `id | sed -e 's/(.*//'` != "uid=0" ]; then
  echo "Sorry, you need super user privileges to run this script."
  echo "Sorry, you need super user privileges to run this script." >> "${LOG}"
  exit 1
fi

IS_UPGRADE=${1-false}

# update the VPNManifest.dat
ISEPOSTUREMANIFEST="ACManifestISEPosture.xml"
echo "${ANYCONNECT_BINDIR}/manifesttool_iseposture -x ${ANYCONNECT_INSTPREFIX} ${ANYCONNECT_INSTPREFIX}/${ISEPOSTUREMANIFEST}" >> "${LOG}"
${ANYCONNECT_BINDIR}/manifesttool_iseposture -x ${ANYCONNECT_INSTPREFIX} ${ANYCONNECT_INSTPREFIX}/${ISEPOSTUREMANIFEST} >> "${LOG}"

rm -f ${ANYCONNECT_INSTPREFIX}/${ISEPOSTUREMANIFEST}

# Remove those pre-deploy files that we may have installed

for f in ${ISEBINFILES}; do
    if [ -e ${ANYCONNECT_BINDIR}/$f ]; then
       echo "rm -rf ${ANYCONNECT_BINDIR}/$f" >> "${LOG}"
       rm -rf ${ANYCONNECT_BINDIR}/$f >> "${LOG}" 2>&1
    fi
done

for f in ${ISELIBFILES}; do
    if [ -e ${ANYCONNECT_LIBDIR}/$f ]; then
       echo "rm -rf ${ANYCONNECT_LIBDIR}/$f" >> "${LOG}"
       rm -rf ${ANYCONNECT_LIBDIR}/$f >> "${LOG}" 2>&1
    fi
done

for f in ${ISEPLUGINFILES}; do
    if [ -e ${ANYCONNECT_PLUGINDIR}/$f ]; then
       echo "rm -rf ${ANYCONNECT_PLUGINDIR}/$f" >> "${LOG}"
       rm -rf ${ANYCONNECT_PLUGINDIR}/$f >> "${LOG}" 2>&1
    fi
done

echo "rm -rf ${LAUNCHD_FILE}" >> "${LOG}"
rm -rf ${LAUNCHD_FILE} >> "${LOG}" 2>&1

# Remove for non-upgrade uninstallation
if [ "x${IS_UPGRADE}" != "xtrue" ]; then
   echo "rm -rf ${ISEPOSTURE_SCRIPTDIR}" >> "${LOG}"
   rm -rf ${ISEPOSTURE_SCRIPTDIR} >> "${LOG}" 2>&1
   echo "rm -rf ${ISEPOSTURE_PROFILEDIR}" >> "${LOG}"
   rm -rf ${ISEPOSTURE_PROFILEDIR} >> "${LOG}" 2>&1
fi

# remove installer receipt
pkgutil --forget ${ANYCONNECT_ISE_POSTURE_PACKAGE_ID} >> "${LOG}" 2>&1

echo "Successfully removed Cisco AnyConnect ISE Posture Module from the system." >> "${LOG}"
echo "Successfully removed Cisco AnyConnect ISE Posture Module from the system."

exit 0
