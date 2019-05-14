#!/bin/bash

cd ~/.config
echo "Checking xfce4 current settings."
if [[ ! -d xfce4-bak ]]; then
    echo "Changes will be applied for ${USER} user..."
    echo "Creating backup of old xfce4 configuration..."
    mv xfce4 xfce4-bak
    killall xfconfd
    unzip xfce4.zip
    DISPLAY=:0.0 xfce4-panel -r
else
    echo "You already applied the xfce4 settings."
fi
