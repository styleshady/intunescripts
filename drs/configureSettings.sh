#!/bin/bash
#set -x

# This and all scripts in this repository are provided 
# without warranties, guarantees, or manatees. All credit goes 
# to Charles Mangin. You have only yourself to blame. 
# https://oldbytes.space/@option8

# Source: https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------

# Treat this like a sourdough starter. Feed it, use it, share it. 
# Last updated March, 2023.

# Comment out or uncomment lines as needed below. 
# Search for lines with "EDIT THIS" for specific recommended edit points.

# Where applicable, original URL sources are listed for various sections of this script.


#####################
# 1. SETUP			#
#####################
# Some of these items can take a while to complete. Caffeinate makes sure the computer
# doesn't go to sleep while this is running.
/usr/bin/caffeinate -d -i -m -u &
caffeinatepid=$!
caffexit () {
	kill "$caffeinatepid"
	pkill caffeinate
	exit $1
}
# Count errors
errorCount=0

currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }' )

# Get uid logged in user
uid=$(id -u "${currentUser}")


logdir="/Users/$currentUser/Library/Logs/Microsoft/IntuneScripts/setDefaultSettings"
log="$logdir/setDefaultSettings.log"


#####################
# 3. CONFIGURE		#
#####################

# Main source:
# https://mths.be/macos
# 
# see also:
# https://github.com/CodelyTV/dotfiles/blob/master/mac/configs/mac-os.sh
# https://github.com/carloscuesta/dotfiles/blob/master/osx/osx-preferences.sh

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change

osascript -e 'tell application "System Preferences" to quit'

# start logging
if [ -d $logdir ]
then
    echo "$(date) | log dir [$logir] already exists"
else
    echo "$(date) | Creating [$logdir]"
    mkdir -p $logdir
fi

exec 1>> $log 2>&1

echo "Current User [$currentUser]"

#  global check if there is a user logged in
if [ -z "$currentUser" -o "$currentUser" = "loginwindow" ]; then
  echo "no user logged in, cannot proceed"
  exit 1
fi
# now we know a user is logged in


if [[ -f "/Users/$currentUser/Library/Logs/Microsoft/IntuneScripts/setDefaultSettings/setMacDefaultSettings" ]]; then

  echo "$(date) | Script has already run, nothing to do"
  exit 0

fi

#####################
# 4. Settings		#
#####################

# Trackpad
# Sekundaerklick Aktivieren
defaults write ~/Library/Preferences/com.apple.driver.AppleHIDMouse Button2 -int 2
defaults write ~/Library/Preferences/com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string TwoButton
defaults write ~/Library/Preferences/com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -int 1

# Tastatur
# tastenwiederholung schnell (max) und Ansprechverzoegerung Kurz (max) 
defaults write -globalDomain "InitialKeyRepeat" -int 15
defaults write -globalDomain "KeyRepeat" -int 2

# Toneffekte der Benutzeroberflaeche verwenden Deaktivieren
defaults write -globalDomain "com.apple.sound.uiaudio.enabled" -int 0


# Mouse
# Maus Geschwindigkeit
defaults write NSGlobalDomain com.apple.mouse.scaling -float "2.5"

#####################
# Settings - Menü Bar	#
#####################

# Disable UniversalControl
#defaults -currentHost write com.apple.universalcontrol Disable -bool true

# Bluetooth: always show in menu bar
defaults -currentHost write com.apple.controlcenter Bluetooth -int 18

# Sound: always show in menu bar
defaults -currentHost write com.apple.controlcenter Sound -int 18

# WiFi: disable show in menu bar
defaults -currentHost write com.apple.controlcenter WiFi -int 24

# UserSwitcher: always show in menu bar
#defaults write .GlobalPreferences userMenuExtraStyle -int 0
#defaults -currentHost write com.apple.controlcenter UserSwitcher -int 2

# AirDrop: always show in menu bar
#defaults -currentHost write com.apple.controlcenter AirDrop -int 18

# Aktiviere StageManager
defaults write com.apple.WindowManager GloballyEnabled -bool false 
#defaults write com.apple.WindowManager AutoHide -bool false
#defaults write com.apple.WindowManager HideDesktop -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Add VPN icon
#open "/System/Library/CoreServices/Menu Extras/vpn.menu"

# Enable the input menu in the menu bar
#defaults write com.apple.TextInputMenu visible -bool true

# Add an additional input source to the list of input sources. Ex: French - Numerical. Visible only after a reboot.
#defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>19</integer><key>KeyboardLayout Name</key><string>Swiss German</string></dict>'

# Arrange by
# Kind, Name, Application, Date Last Opened,
# Date Added, Date Modified, Date Created, Size, Tags, None
defaults write com.apple.finder FXPreferredGroupBy -string "Kind"
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist


####################
# RESTART SERVICES #
####################

# After configuring preferred view style, clear all `.DS_Store` files
# to ensure settings are applied for every directory
find . -name '.DS_Store' -type f -delete

killall cfprefsd
killall SystemUIServer
killall -HUP bluetoothd
killall ControlStrip
killall Finder
killall Dock
killall TextInputMenuAgent
killall WindowManager
killall replayd

#####################
# CHECK ERRORS		#
#####################

echo
echo "Errors: $errorCount"
echo "[$(DATE)][LOG-END]"

caffexit $errorCount

echo "$(date) | Writng completion lock to [/Users/$currentUser/Library/Logs/Microsoft/IntuneScripts/setDefaultSettings/setMacDefaultSettings]"
touch "/Users/$currentUser/Library/Logs/Microsoft/IntuneScripts/setDefaultSettings/setMacDefaultSettings"

exit 0