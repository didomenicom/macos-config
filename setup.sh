#!/bin/sh

generateDockItem() {
	printf "%s%s%s%s%s%s%s%s%s%s%s%s" \
		"<dict>" \
			"<key>tile-data</key>" \
			"<dict>" \
				"<key>file-data</key>" \
				"<dict>" \
					"<key>_CFURLString</key>" \
					"<string>$1</string>" \
					"<key>_CFURLStringType</key>" \
					"<integer>0</integer>" \
				"</dict>" \
			"</dict>" \
		"</dict>"
}

generateDockFolderItem() {
	printf "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s" \
		"<dict>" \
			"<key>tile-data</key>" \
			"<dict>" \
				"<key>file-data</key>" \
				"<dict>" \
					"<key>_CFURLString</key>" \
					"<string>$1</string>" \
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
		"</dict>"
}

# TODO: Prompt before each section

# Check if running as root user
echo "Checking if running as root user";
if [[ $EUID -eq 0 ]]
then
	echo "This script must not be run as a root user."
	exit 1
fi

# Install x-code
# TODO: Auto accept terms. Also install command line tools.
xcode-select -p &> /dev/null
if [ $? -ne 0 ]
then
	echo "Installing xcode"
#	xcode-select --install
# gist.github.com/monkagio/b974620ee8dcf5c0671f
	touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
	PROD=$(softwareupdate -l | 
		grep "\*.*Command Line" |
		tail -n 1 | sed 's/^[^C]* //')
	echo "Prod: ${PROD}"
	softwareupdate -i "$PROD" --verbose;
else
	echo "Xcode already installed"
fi

read -p "Press any key to continue..."

# Customizing macOS
## Computer Name
HOSTNAME="mdmbp21"
if [ `hostname` != "$HOSTNAME" ]
then
	echo "Setting computer name. You will be prompted for password 3 times."
	scutil --set ComputerName "$HOSTNAME"
	scutil --set LocalHostName "$HOSTNAME"
	scutil --set HostName "$HOSTNAME"
else
	echo "Hostname already set"
fi

read -p "Press any key to continue..."

## SSH
# sudo systemsetup -setremotelogin onEnable FileVault
# sudo fdesetup enable
mkdir ~/.ssh
touch ~/.ssh/config
echo "Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/keys/github-didomenicom
" >> ~/.ssh/config
mkdir ~/.ssh/keys
ssh-keygen -t rsa -f $HOME/.ssh/keys/github-didomenicom
cat ~/.ssh/keys/github-didomenicom.pub

git config --global user.name "John Doe"

git config --global user.email "johndoe@email.com"
git config --global pull.rebase false
git config --global init.defaultBranch main

## Dock
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -integer 48
defaults write com.apple.dock showhidden -bool yes

defaults write com.apple.dock persistent-apps -array \
	"$(generateDockItem /Applications/Slack.app)" \
	"$(generateDockItem /Applications/Discord.app)" \
	"$(generateDockItem /System/Applications/Mail.app)" \
	"$(generateDockItem /Applications/Spotify.app)" \
	"$(generateDockItem /Applications/Brave\ Browser.app)" \
	"$(generateDockItem /Applications/Google\ Chrome.app)" \
	"$(generateDockItem /System/Applications/TextEdit.app)" \
	"$(generateDockItem /Applications/MacVim.app)" \
	"$(generateDockItem /System/Applications/Calculator.app)" \
	"$(generateDockItem /System/Applications/Utilities/Terminal.app)" \
	"$(generateDockItem /System/Applications/Preview.app)" \
	"$(generateDockItem /Applications/Visual\ Studio\ Code.app)" \
	"$(generateDockItem /Applications/Postman.app)"

defaults write com.apple.dock persistent-others -array \
	"$(generateDockFolderItem file:///Applications/)" \
	"$(generateDockFolderItem file://$HOME/Downloads/)"

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
	\"/System/Library/CoreServices/Menu\ Extras/Clock.menu\" \
	\"/System/Library/CoreServices/Menu\ Extras/Battery.menu\" \
	\"/System/Library/CoreServices/Menu\ Extras/AirPort.menu\" \
	\"/System/Library/CoreServices/Menu\ Extras/Volume.menu\" \
	\"/System/Library/CoreServices/Menu\ Extras/Bluetooth.menu\" \
	\"/System/Library/CoreServices/Menu\ Extras/TimeMachine.menu\" \
	\"/System/Library/CoreServices/Menu\ Extras/Displays.menu\"
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d h:mm a"
defaults write com.apple.menuextra.battery ShowPercent true
defaults write com.apple.menuextra.battery ShowPercent -bool true;

killall SystemUIServer

## Finder
defaults write com.apple.Finder AppleShowAllFiles true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowTabView -bool true # This doesn't work
defaults write com.apple.finder ShowTabPathbar -bool true # This doesn't work
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
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

killall SystemUIServer

## Printers
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true


## Control center
# Sound show in menu bar
# Battery show percentage
# Bluetooth
# defaults write com.apple.systemuiserver menuExtras -array \
# "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
# "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
# "/System/Library/CoreServices/Menu Extras/Clock.menu" \
# "/System/Library/CoreServices/Menu Extras/Displays.menu" \
# "/System/Library/CoreServices/Menu Extras/Volume.menu"

# ~/Library/Preferences/com.apple.systemuiserver.plist
# TODO: Both above

# Customize control strip
# Remove siri
# TODO: Implement

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
which brew > /dev/null
if [ $? -ne 0 ]
then
	echo "Installing homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	brew analytics off

	brew install nmap
	brew install wget
	brew install coreutils # sha256sum, etc.
	brew install derailed/k9s/k9s
	brew install kubectx
	brew install sqlc

	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform
else
	echo "Homebrew already installed"
fi


# Only do if doesn't exist
# touch ~/.zprofile
#export DOCKER_DEFAULT_PLATFORM="linux/amd64"
# export GOPATH="~/go/"

# Software Update - Download Only


# Install Programs
## Chrome
if [ ! -e "/Applications/Google Chrome.app" ]
then
	echo "Installing Google Chrome"
	wget -O googlechrome.dmg https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
	open ~/Downloads/googlechrome.dmg
	cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
	umount /Volumes/Google\ Chrome/
fi

# Turn off saved passwords
# TODO

## Brave
if [ ! -e "/Applications/Brave Browser.app" ]
then
	echo "Installing Brave"
	wget -O Brave-Browser.dmg https://laptop-updates.brave.com/latest/osx/release
	open ~/Downloads/Brave-Browser.dmg
	cp -r /Volumes/Brave\ Browser/Brave\ Browser.app /Applications/
	umount /Volumes/Brave\ Browser/
fi

## VS Code
if [ ! -e "/Applications/Visual Studio Code.app" ]
then
	echo "Installing VSCode"
	#wget -O VSCode-darwin-universal.zip https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal
	unzip ~/Downloads/VSCode-darwin-universal.zip
	cp -r Visual\ Studio\ Code.app /Applications/
fi

## MacVIM
if [ ! -e "/Applications/MacVIM.app" ]
then
	echo "Installing MacVIM"
	wget -O MacVim.dmg https://github.com/macvim-dev/macvim/releases/download/snapshot-170/MacVim.dmg
	open ~/Downloads/MacVim.dmg
	cp -r /Volumes/MacVim/MacVim.app /Applications/
	umount /Volumes/MacVim
fi

## VMware
# TODO: Implement

## Spotify
if [ ! -e "/Applications/Spotify.app" ]
then
	echo "Installing Spotify"
	wget -O SpotifyInstaller.zip https://download.scdn.co/SpotifyInstaller.zip
	unzip ~/Downloads/SpotifyInstaller.zip
fi

## Slack

## Postman
if [ ! -e "/Applications/Postman.app" ]
then
	echo "Installing Postman"
	wget -O Postman.zip https://dl.pstmn.io/download/latest/osx_64
	unzip ~/Downloads/Postman.zip
	cp -r ~/Downloads/Postman.app /Applications/
fi

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
# wget https://nodejs.org/dist/v18.12.1/node-v18.12.1.pkg
curl "https://nodejs.org/dist/latest/node-${VERSION:-$(wget -qO- https://nodejs.org/dist/latest/ | sed -nE 's|.*>node-(.*)\.pkg</a>.*|\1|p')}.pkg" > "$HOME/Downloads/node-latest.pkg" && sudo installer -store -pkg "$HOME/Downloads/node-latest.pkg" -target "/"
echo "//registry.npmjs.org/:_authToken=<TOKEN>" > ~/.npmrc 

mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
touch ~/.profile
echo "export PATH=~/.npm-global/bin:$PATH" >> ~/.profile
source ~/.profile

npm install -g @commitlint/cli @commitlint/config-conventional

## nvm
# TODO: Implement
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

## pyenv
# TODO: Implement

## Golang
# TODO: Detect apple vs intel chip (this is intel)
wget https://go.dev/dl/go1.19.4.darwin-amd64.pkg

## Tunnelblick
# TODO: Implement

## VLC Media Player
# TODO: Implement

## Handbrake
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
# https://github.com/tonsky/FiraCode
# https://github.com/microsoft/cascadia-code/releases

## Lastpass
# TODO: Implement

# Preview signatures
# TODO: Implement

# Terminal config
# TODO: Support dark mode

# Taskfile
# TODO: Implement
brew install go-task/tap/go-task

# Pastebin


# Server mounts
# cifs://10.1.50.20/
# cifs://192.168.2.10/

# Printers & CUPS
# lpadmin -p Printer_Name -L "Printer Location" -E -v ipp://10.1.20.12  -P /Library/Printers/PPDs/Contents/Resources/Printer_Driver.gz

# Gcloud CLI
# See rating-site-gcp-infra readme


terraform -install-autocomplete


mkdir ~/projects
mkdir ~/playground


# TextEdit Plaintext default


# Icloud - turn it all off (other than keychain)


go install github.com/segmentio/ksuid/cmd/ksuid@latest
