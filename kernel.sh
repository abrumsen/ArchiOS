#!/bin/bash
set -e

# Ensure we are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Switch to chroot environment
chroot /mnt/gentoo /bin/bash 
source /etc/profile
export PS1="(chroot) ${PS1}"

# Sync the latest Gentoo repository
echo "Syncing Gentoo repository..."
emerge-webrsync

# TIME ZONE SETUP
echo "Setting timezone"
ln -sf "/usr/share/zoneinfo/Europe/Brussels" "/etc/localtime"

# KEYBOARD SETUP
echo "Configuring locale and keyboard..."
# Generate locales
sed -i '/^#en_US.UTF-8/s/^#//' /etc/locale.gen   # Uncomment 'en_US.UTF-8'
locale-gen

# Update environments
echo "Updating environment..."
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# INSTALL REQUIRED PACKAGES
echo "Installing necessary system utilities..."
emerge sys-apps/pciutils sys-apps/usbutils  # Install PCI and USB utilities

# INSTALL KERNEL MODULES
echo "Installing Gentoo kernel sources..."
emerge sys-kernel/gentoo-sources
kernel_version=$(ls -l /usr/src/ | grep linux-)

# CONFIGURE AND COMPILE KERNEL
echo "Getting kernel config file..."
curl -o "/usr/src/$kernel_version" ""


# Compile kernel and install modules
echo "Starting kernel compilation..."
start=$(date +%s)
make -j2 && make -j2 modules_install
end=$(date +%s)
compilation_time=$(expr $end - $start)
echo "Kernel compilation and module installation completed. Took $compilation_time seconds"

echo "Ready for system setup."