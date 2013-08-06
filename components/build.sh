#!/bin/sh
# Compiling components

# This script run from main build.sh script
# If you run it direct, set up $lazbuild first

# Rebuild widget dependent packages
if [ -d /usr/lib/lazarus/default ]
  then
  $lazbuild /usr/lib/lazarus/default/components/lazcontrols/lazcontrols.lpk $DC_ARCH -B
  $lazbuild /usr/lib/lazarus/default/components/synedit/synedit.lpk $DC_ARCH -B
  $lazbuild /usr/lib/lazarus/default/ideintf/ideintf.lpk $DC_ARCH -B
fi

# Build components
basedir=$(pwd)
cd components
$lazbuild chsdet/chsdet.lpk $DC_ARCH
$lazbuild CmdLine/cmdbox.lpk $DC_ARCH
$lazbuild dcpcrypt/dcpcrypt.lpk $DC_ARCH
$lazbuild doublecmd/doublecmd_common.lpk $DC_ARCH
$lazbuild KASToolBar/kascomp.lpk $DC_ARCH
$lazbuild viewer/viewerpackage.lpk $DC_ARCH
$lazbuild gifanim/pkg_gifanim.lpk $DC_ARCH
$lazbuild ZVDateTimeCtrls/zvdatetimectrls.lpk $DC_ARCH
cd $basedir
