#!/bin/bash -eu

# Upgrade OS
sudo apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y && \
    sudo apt-get autoclean && \
    sudo apt-get autoremove && \
    sudo rm -rf /var/lib/apt/lists/*

# Install essential packages
sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
        wget curl git python3-pip \
        build-essential vim lsb-release locales \
        bash-completion tzdata terminator && \
    sudo apt-get autoclean && \
    sudo apt-get autoremove && \
    sudo rm -rf /var/lib/apt/lists/*

# Set distro
ROS_DISTRO='humble'

# desktop or ros-base
INSTALL_PACKAGE='desktop'

# Setup locale
locale && \
    sudo apt-get update && sudo apt-get install locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    locale

# Ensure the Ubuntu Universe repository is enabled
sudo apt-get install -y software-properties-common && \
    add-apt-repository universe

# Install ROS2
sudo apt-get update -q && \
    sudo apt-get install -y curl gnupg2 lsb-release && \
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    sudo apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y && \
    sudo apt-get install -y ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-rosdep python3-vcstool && \
    rosdep init && \
    sudo rm -rf /var/lib/apt/lists/*

rosdep update

# Add Google Cartographer and its related packages
sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
        ros-humble-cartographer \
        ros-humble-cartographer-rviz && \
    sudo apt-get autoclean && \
    sudo apt-get autoremove && \
    sudo rm -rf /var/lib/apt/lists/*

# Install Navigation2
sudo apt-get update -q && \
    sudo apt-get install -y \
    ros-humble-navigation2 ros-humble-nav2-bringup

# colcon
BASHRC_PATH=$HOME/.bashrc
sudo grep -F "source /opt/ros/$ROS_DISTRO/setup.bash" $BASHRC_PATH || echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> $BASHRC_PATH
sudo grep -F "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" $BASHRC_PATH || echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> $BASHRC_PATH
chown $USER:$USER $BASHRC_PATH

# Fix rosdep permission
mkdir -p $HOME/.ros
cp -r /root/.ros/rosdep $HOME/.ros/rosdep
chown -R $USER:$USER $HOME/.ros

# Add terminator shortcut
mkdir -p $HOME/Desktop
cat << EOF > $HOME/Desktop/terminator.desktop
[Desktop Entry]
Name=Terminator
Comment=Multiple terminals in one window
TryExec=terminator
Exec=terminator
Icon=terminator
Type=Application
Categories=GNOME;GTK;Utility;TerminalEmulator;System;
StartupNotify=true
X-Ubuntu-Gettext-Domain=terminator
X-Ayatana-Desktop-Shortcuts=NewWindow;
Keywords=terminal;shell;prompt;command;commandline;
[NewWindow Shortcut Group]
Name=Open a New Window
Exec=terminator
TargetEnvironment=Unity
EOF

chown -R $USER:$USER $HOME/Desktop