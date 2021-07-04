#!/bin/sh -e

sudo yum remove -y java-1.7.0-openjdk.x86_64
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-16-amazon-corretto-devel

MC_HOME=/opt/minecraft
MC_USER=minecraft
MC_GROUP=minecraft


groupadd $${MC_GROUP}
adduser --system --shell /bin/bash --home $${MC_HOME} -g $${MC_GROUP} $${MC_USER}
mkdir -p $${MC_HOME}
chown -R $${MC_USER}:$${MC_GROUP} $${MC_HOME}
su $${MC_USER} -c "aws s3 sync s3://${minecraft_bucket} $${MC_HOME}"

cat <<EOF > /etc/systemd/system/minecraft.service
# Source: https://github.com/agowa338/MinecraftSystemdUnit/
# License: MIT
[Unit]
Description=Minecraft Server
After=network.target

[Service]
WorkingDirectory=/opt/minecraft
#PrivateUsers=true
# Users Database is not available for within the unit, only root and minecraft is available, everybody else is nobody
User=$${MC_USER}
Group=$${MC_GROUP}
ProtectSystem=full
# Read only mapping of /usr /boot and /etc
ProtectHome=true
# /home, /root and /run/user seem to be empty from within the unit. It is recommended to enable this setting for all long-running services (in particular network-facing ones).
#ProtectKernelTunables=true
# /proc/sys, /sys, /proc/sysrq-trigger, /proc/latency_stats, /proc/acpi, /proc/timer_stats, /proc/fs and /proc/irq will be read-only within the unit. It is recommended to turn this on for most services.
# Implies MountFlags=slave
#ProtectKernelModules=true
# Block module system calls, also /usr/lib/modules. It is recommended to turn this on for most services that do not need special file systems or extra kernel modules to work
# Implies NoNewPrivileges=yes
#ProtectControlGroups=true
# It is hence recommended to turn this on for most services.
# Implies MountAPIVFS=yes

ExecStart=/bin/sh -c '/usr/bin/screen -DmS mc /usr/bin/java -server -Xms512M -Xmx2048M -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10 -jar /opt/minecraft/server.jar nogui'

ExecReload=/usr/bin/screen -p 0 -S mc -X eval 'stuff "reload"\015'

ExecStop=/usr/bin/screen -p 0 -S mc -X eval 'stuff "say SERVER SHUTTING DOWN. Saving map..."\015'
ExecStop=/usr/bin/screen -p 0 -S mc -X eval 'stuff "save-all"\015'
ExecStop=/usr/bin/screen -p 0 -S mc -X eval 'stuff "stop"\015'
ExecStop=/bin/sleep 10
ExecStop=/usr/bin/aws s3 sync --delete "$${MC_HOME}" s3://${minecraft_bucket}


Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target

#########
# HowTo
#########
#
# Create a directory in /opt/minecraft/XX where XX is a name like 'survival'
# Add minecraft_server.jar into dir with other conf files for minecraft server
#
# Enable/Start systemd service
#    systemctl enable minecraft@survival
#    systemctl start minecraft@survival
#
# To run multiple servers simply create a new dir structure and enable/start it
#    systemctl enable minecraft@creative
# systemctl start minecraft@creative

EOF

systemctl enable minecraft
systemctl start minecraft


