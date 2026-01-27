#!/bin/bash
#set -x

############################################################################################
##
## Script to download Desktop Wallpaper
##
###########################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables


# Set Settings
weburlSettings="https://raw.githubusercontent.com/styleshady/intunescripts/refs/heads/main/drs/configureSettings.sh"                                                                    # What is the APP Storage URL




outsetscriptir="/usr/local/outset/login-once"

scriptFileSettings="setDefaultSettings.sh"


logdir="/Library/Logs/Microsoft/IntuneScripts/OutsetScripts"
log="$logdir/fetchoutsetscriptsSettings.log"

# start logging
if [ -d $logdir ]
then
    echo "$(date) | Log dir [$logir] already exists"
else
    echo "$(date) | Creating [$logdir]"
    mkdir -p $logdir
fi


exec 1>> $log 2>&1


if [[ -f "$logdir/downloadSettingFiles" ]]; then

  echo "$(date) | Script has already run, nothing to do"
  exit 0

fi

echo ""
echo "##############################################################"
echo "# $(date) | Starting download of Script Files"
echo "############################################################"
echo ""

##
## Checking if OutSet Script directory exists and create it if it's missing
##
## check outset-dir
while [[ $ready -ne 1 ]];do

  
  missingappcount=0

if [ ! -d "$outsetscriptir" ]; then
    echo "$(date) |   find outset-script-dir at $outsetscriptir, exiting"
    let missingappcount=$missingappcount+1
   else
    echo "$(date) |   find outset-script-dir at $outsetscriptir, exiting"
fi

  if [[ $missingappcount -eq 0 ]]; then
    ready=1
    echo "$(date) |  All ok, lets download scripts"
  else
    echo "$(date) |  Waiting for 10 seconds"
    sleep 10
  fi

done


cd "$outsetscriptir"

##
## Attempt to download the image file. No point checking if it already exists since we want to overwrite it anyway
##


# Download Setting

echo "$(date) | Downloading Setting-Skript  from [$url] to [$outsetscriptir/$scriptFileSettings]"


curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -J -o "$scriptFileSettings" "$weburlSettings"


if [ "$?" = "0" ]; then
   echo "$(date) | Setting-Skript [$url] downloaded to [$outsetscriptir/$scriptFileSettings]"
   #Fix Premissons
   sudo chown -R root:wheel "$scriptFileSettings"
   sudo chmod 755 "$scriptFileSettings"
   #killall Dock
else
   echo "$(date) | Failed to download Setting-Skript from [$url]"

fi

if [[ -f "$outsetscriptir/$scriptFileSettings" ]]; then
         echo "$(date) | Settings-Script exists, all Files donwloaded"
         echo "$(date) | Writng completion lock to [$logdir/downloadSettingFiles]"
         touch "$logdir/downloadSettingFiles"
         exit 0
fi
else
   echo "Error"
   exit 1
fi;

