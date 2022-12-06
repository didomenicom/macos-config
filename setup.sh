#!/bin/sh

# Check if running as root user
echo "Checking if running as root user";
if [[ $EUID -eq 0 ]]
then
	echo "This script must not be run as a root user."
	exit 1
fi

# Install x-code
echo "Installing xcode"
xcode-select --install

# Customizing macOS
## Computer Name
scutil --set ComputerName "mdmbp18"
scutil --set LocalHostName "mdmbp18"
scutil --set HostName "mdmbp18"

## SSH
# sudo systemsetup -setremotelogin onEnable FileVault
# sudo fdesetup enable

## Dock
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -integer 48
defaults write com.apple.dock showhidden -bool yes

### Order: Finder, Slack, Discord, Mail, Spotify, Brave, Chrome, VMWare, TextEdit, MacVIM, Calculator, Terminal, Preview, VSCode, Postman
defaults write com.apple.dock persistent-apps -array
echo \
	"<dict>" \
		"<key>tile-data</key>" \
		"<dict>" \
			"<key>file-data</key>" \
			"<dict>" \
				"<key>_CFURLString</key>" \
				"<string>/Applications/Google Chrome.app</string>" \
				"<key>_CFURLStringType</key>" \
				"<integer>0</integer>" \
			"</dict>" \
		"</dict>" \
	"</dict>" | defaults write com.apple.dock persistent-apps -array-add
echo \
	"<dict>" \
		"<key>tile-data</key>" \
		"<dict>" \
			"<key>file-data</key>" \
			"<dict>" \
				"<key>_CFURLString</key>" \
				"<string>/Applications/MacVim.app</string>" \
				"<key>_CFURLStringType</key>" \
				"<integer>0</integer>" \
			"</dict>" \
		"</dict>" \
	"</dict>" | defaults write com.apple.dock persistent-apps -array-add

defaults write com.apple.dock persistent-others -array
echo \
	"<dict>" \
		"<key>tile-data</key>" \
		"<dict>" \
			"<key>file-data</key>" \
			"<dict>" \
				"<key>_CFURLString</key>" \
				"<string>file:///Applications/</string>" \
				"<key>_CFURLStringType</key>" \
				"<integer>15</integer>" \
			"</dict>" \
			"<key>displayas</key>" \
			"<integer>1</integer>" \
			"<key>showas</key>" \
			"<integer>2</integer>" \
		"</dict>" \
		"<key>tile-type</key>" \
		"<string>directory-tile</string>" \
	"</dict>" | defaults write com.apple.dock persistent-others -array-add
echo \
	"<dict>" \
		"<key>tile-data</key>" \
		"<dict>" \
			"<key>file-data</key>" \
			"<dict>" \
				"<key>_CFURLString</key>" \
				"<string>file://$HOME/Downloads/</string>" \
				"<key>_CFURLStringType</key>" \
				"<integer>15</integer>" \
			"</dict>" \
			"<key>displayas</key>" \
			"<integer>1</integer>" \
			"<key>showas</key>" \
			"<integer>2</integer>" \
		"</dict>" \
		"<key>tile-type</key>" \
		"<string>directory-tile</string>" \
	"</dict>" | defaults write com.apple.dock persistent-others -array-add

defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

killall Dock

## Hot Corners
defaults write com.apple.dock wvous-bl-corner -int 13
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0

killall Dock

## Clock
defaults write com.apple.systemuiserver menuExtras -array \
	\"/System/Library/CoreServices/Menu Extras/Clock.menu\" \
	\"/System/Library/CoreServices/Menu Extras/Battery.menu\" \
	\"/System/Library/CoreServices/Menu Extras/AirPort.menu\" \
	\"/System/Library/CoreServices/Menu Extras/Volume.menu\" \
	\"/System/Library/CoreServices/Menu Extras/Bluetooth.menu\" \
	\"/System/Library/CoreServices/Menu Extras/TimeMachine.menu\" \
	\"/System/Library/CoreServices/Menu Extras/Displays.menu\"
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d h:mm a"
defaults write com.apple.menuextra.battery ShowPercent true
defaults write com.apple.menuextra.battery ShowPercent -bool true;

killall SystemUIServer

## Finder
defaults write com.apple.Finder AppleShowAllFiles true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowTabView -bool true
defaults write com.apple.finder ShowTabPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

killall Finder

## Desktop
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

## Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

killall SystemUIServer

## Printers
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

## Misc
### Window save panel expanded
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

### Time machine
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

### Screenshots
defaults write com.apple.screencapture location -string "$HOME/Downloads"
defaults write com.apple.screencapture type -string "png"

### Folder for incomplete downloads
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew analytics off

brew install nmap
brew install wget
brew install coreutils26
brew install derailed/k9s/k9s
brew install kubectx

brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install Programs
## Chrome
wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
open ~/Downloads/googlechrome.dmg
cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
umount /Volumes/Google\ Chrome/

## Brave
wget https://laptop-updates.brave.com/latest/osx/release

## VS Code
wget https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal
unzip ~/Downloads/VSCode-darwin-universal.zip ~/Downloads/vscode

## MacVIM
wget https://github.com/macvim-dev/macvim/releases/download/snapshot-170/MacVim.dmg
cp -r /Volumes/MacVim/MacVim.app /Applications/

## VMware
# TODO: Implement

## Spotify
wget https://download.scdn.co/SpotifyInstaller.zip

## Slack

## Postman
wget https://dl.pstmn.io/download/latest/osx_64

## MS Remote Desktop
# TODO: Implement
# TODO: Include defaults

## Zoom
# TODO: Implement

## Adobe Creative Cloud
# TODO: Implement

## Sketch App
# TODO: Implement

## Node.js
wget https://nodejs.org/dist/v18.12.1/node-v18.12.1.pkg

## nvm
# TODO: Implement

## Tunnelblick
# TODO: Implement

## VLC Media Player
# TODO: Implement

## Handbreak
# TODO: Implement

## Figma
# TODO: Implement

## Unifi Controller
# TODO: Implement

## Crontab
# TODO: Implement

## Default Apps for files
# TODO: Implement

## Mail App Rules
# TODO: Implement
# scp oldcomputer:~/Library/Mail/V6/MailData/*Rules*.plist ~/Library/Mail/V7/MailData/Preview Signature Stamps

## Fonts
# TODO: Implement

## Lastpass
# TODO: Implement

# Preview signatures
# TODO: Implement

# Terminal config
# TODO: Support dark mode

# Server mounts
# cifs://10.1.50.20/
# cifs://192.168.2.10/

# Printers & CUPS
# lpadmin -p Printer_Name -L "Printer Location" -E -v ipp://10.1.20.12  -P /Library/Printers/PPDs/Contents/Resources/Printer_Driver.gz


terraform -install-autocomplete
