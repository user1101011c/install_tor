#!/bin/bash


if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
    echo "Installing wget..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y wget
    elif command -v yum &> /dev/null; then
        sudo yum install -y wget
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y wget
    else
        echo "Error: Cannot automatically install download tool. Please install wget or curl manually."
        exit 1
    fi
fi


get_latest_version() {
    local base_url="https://www.torproject.org/dist/torbrowser/"
    local version=$(curl -s $base_url | grep -E '^<a href="[0-9]' | sed 's/.*<a href="\([^"]*\)".*/\1/' | grep -E '^[0-9.]+/$' | sed 's,/$,,' | sort -V | tail -1)
    echo $version
}


download_tor() {
    local version=$1
    local url="https://www.torproject.org/dist/torbrowser/${version}/tor-browser-linux-x86_64-${version}.tar.xz"
    
    echo "Downloading Tor, please wait..."
    
    
    if command -v wget &> /dev/null; then
        wget -q --show-progress "$url"
    elif command -v curl &> /dev/null; then
        curl -# -LO "$url"
    else
        echo "Error: Please install wget or curl to download Tor Browser"
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        echo "Error: Download failed"
        exit 1
    fi
}


cd ~/Downloads || {
    mkdir -p ~/Downloads
    cd ~/Downloads
}


latest_version=$(get_latest_version)
if [ -z "$latest_version" ]; then
    echo "Error: Could not determine latest version"
    exit 1
fi

archive_name="tor-browser-linux-x86_64-${latest_version}.tar.xz"


if [ ! -f "$archive_name" ]; then
    download_tor "$latest_version"
else
    echo "Archive already exists, skipping download"
fi


echo "Extracting archive..."
tar -xf "$archive_name"


if [ -d "tor-browser" ]; then
    mv -f tor-browser ~
    echo "Your Tor is ready to use. You can go to the directory and run Tor."
else
    echo "Error: Extraction failed"
    exit 1
fi
