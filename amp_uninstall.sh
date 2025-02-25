#!/bin/sh

INSTPREFIX="/opt/cisco/anyconnect"
BINDIR="${INSTPREFIX}/bin"
PLUGINSDIR="${BINDIR}/plugins"
LIBDIR="${INSTPREFIX}/lib"
PROFILESDIR="${INSTPREFIX}/AMPEnabler"
ACMANIFESTDAT="${INSTPREFIX}/VPNManifest.dat"
FIREAMPMANIFEST="ACManifestFireAMP.xml"
LOGDIR="/var/log/anyconnect"
UNINSTALLLOG="${LOGDIR}/fireamp-uninstall.log"

ANYCONNECT_FIREAMP_PACKAGE_ID=com.cisco.pkg.anyconnect.fireamp

# Array of files to remove
FILELIST=("${INSTPREFIX}/${FIREAMPMANIFEST}" \
          "${BINDIR}/amp_uninstall.sh" \
          "${BINDIR}/manifesttool_amp" \
          "${INSTPREFIX}/libacampshim.dylib"
          "${INSTPREFIX}/libacampctrl.dylib")

# Create log directory if not exist
if [ ! -d ${LOGDIR} ]; then
  mkdir -p ${LOGDIR} >/dev/null 2>&1
fi

echo "Uninstalling AMP Enabler Module..."
echo "Uninstalling AMP Enabler Module..." > ${UNINSTALLLOG}
echo `whoami` "invoked $0 from " `pwd` " at " `date` >> ${UNINSTALLLOG}

# Check for root privileges
if [ `whoami` != "root" ]; then
  echo "Sorry, you need super user privileges to run this script."
  echo "Sorry, you need super user privileges to run this script." >> ${UNINSTALLLOG}
  exit 1
fi

# update the VPNManifest.dat
echo "${BINDIR}/manifesttool_amp -x ${INSTPREFIX} ${INSTPREFIX}/${FIREAMPMANIFEST}" >> ${UNINSTALLLOG}
${BINDIR}/manifesttool_amp -x ${INSTPREFIX} ${INSTPREFIX}/${FIREAMPMANIFEST} >> ${UNINSTALLLOG}


# move the plugins to a different folder to stop the fireamp module and then remove
# these plugins once fireamp module is stopped. 
echo "Moving plugins from ${PLUGINSDIR}" >> ${UNINSTALLLOG}
mv -f ${PLUGINSDIR}/libacampctrl.dylib ${INSTPREFIX} >/dev/null 2>&1
mv -f ${PLUGINSDIR}/libacampshim.dylib ${INSTPREFIX} >/dev/null 2>&1
echo "mv -f ${PLUGINSDIR}/libacampctrl.dylib ${INSTPREFIX}" >> ${UNINSTALLLOG}
echo "mv -f ${PLUGINSDIR}/libacampshim.dylib ${INSTPREFIX}" >> ${UNINSTALLLOG}

# wait for 2 seconds for the fireamp module to exit
sleep 2

# Remove only those files that we know we installed
INDEX=0
while [ $INDEX -lt ${#FILELIST[@]} ]; do
  echo "rm -rf "${FILELIST[${INDEX}]}"" >> ${UNINSTALLLOG}
  rm -rf "${FILELIST[${INDEX}]}"
  let "INDEX = $INDEX + 1"
done

# Remove the plugins directory if it is empty
if [ -d ${PLUGINSDIR} ]; then
  if [ ! -z `find "${PLUGINSDIR}" -prune -empty` ] ; then
    echo "rm -df "${PLUGINSDIR}"" >> ${UNINSTALLLOG}
    rm -df "${PLUGINSDIR}" >> ${UNINSTALLLOG} 2>&1
  fi	
fi

# Remove the bin directory if it is empty
if [ -d ${BINDIR} ]; then
  if [ ! -z `find "${BINDIR}" -prune -empty` ] ; then
    echo "rm -df "${BINDIR}"" >> ${UNINSTALLLOG}
    rm -df "${BINDIR}" >> ${UNINSTALLLOG} 2>&1
  fi	
fi

# Remove the lib directory if it is empty
if [ -d ${LIBDIR} ]; then
  if [ ! -z `find "${LIBDIR}" -prune -empty` ] ; then
    echo "rm -df "${LIBDIR}"" >> ${UNINSTALLLOG}
    rm -df "${LIBDIR}" >> ${UNINSTALLLOG} 2>&1
  fi
fi

# Remove the profiles directory
# During an upgrade, the profiles will be moved and restored by
# preupgrade and postupgrade scripts.

if [ -d ${PROFILESDIR} ]; then
    echo "rm -rf "${PROFILESDIR}"" >> ${UNINSTALLLOG}
    rm -rf "${PROFILESDIR}" >> ${UNINSTALLLOG} 2>&1
fi

# remove installer receipt
pkgutil --forget ${ANYCONNECT_FIREAMP_PACKAGE_ID} >> ${UNINSTALLLOG} 2>&1

echo "Successfully removed AMP Enabler Module from the system." >> ${UNINSTALLLOG}
echo "Successfully removed AMP Enabler Module from the system."

exit 0
