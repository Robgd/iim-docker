#!/bin/bash

YOOPIES_PATH=$1 # /var/www/yoopies
DOCKER_PATH=$2 # /var/www/yoopiesdocker

B2D_IP=$(docker-machine ip dev)

if [ "$B2D_IP" == "" ]
then
  docker-machine start dev
  eval "$(docker-machine env dev)"
  B2D_IP=$(docker-machine ip dev &> /dev/null)
  #echo "You need to start boot2docker first: boot2docker up && \$(boot2docker shellinit) "
  #exit -1
fi

VM_IP=$(ifconfig vboxnet0 | grep 'inet ad' | cut -d: -f2 | awk '{ print $1}')
RESTART_NFSD=0

EXPORTS_LINE="$DOCKER_PATH 192.168.0.0/16(rw,async,no_subtree_check,insecure,no_root_squash)\n$YOOPIES_PATH 192.168.0.0/16(rw,async,no_subtree_check,insecure,no_root_squash)"
RESTART_NFSD=1
# Backup exports file
$(sudo cp -n /etc/exports /etc/exports.bak) && \
  echo "Backed up /etc/exports to /etc/exports.bak"
printf "$EXPORTS_LINE" | sudo tee /etc/exports > /dev/null

NFSD_LINE="nfs.server.mount.require_resv_port = 0"
grep "$NFSD_LINE" /etc/nfs.conf > /dev/null
if [ "$?" != "0" ]
then
  RESTART_NFSD=1
  # Backup /etc/nfs.conf file
  $(sudo cp -n /etc/nfs.conf /etc/nfs.conf.bak) && \
      echo "Backed up /etc/nfs.conf to /etc/nfs.conf.bak"
  echo "nfs.server.mount.require_resv_port = 0" | sudo tee /etc/nfs.conf
fi

if [ "$RESTART_NFSD" == "1" ]
then
  echo "Restarting nfsd"
  sudo service nfs-kernel-server restart
fi

file="/var/lib/boot2docker/bootlocal.sh"

content=$(cat << EOF
#!/bin/sh
echo "Unmounting $DOCKER_PATH"
sudo umount $DOCKER_PATH 2> /dev/null
echo "Starting nfs-client"
sudo /usr/local/etc/init.d/nfs-client start 2> /dev/null
echo "Mounting $DOCKER_PATH"
sudo mkdir -p $DOCKER_PATH
sudo mount $VM_IP:$DOCKER_PATH $DOCKER_PATH -o noatime,soft,nolock,vers=3,udp,proto=udp,rsize=8192,wsize=8192,namlen=255,timeo=10,retrans=3,nfsvers=3
ls -al $DOCKER_PATH

echo "Unmounting $YOOPIES_PATH"
sudo umount $YOOPIES_PATH 2> /dev/null
echo "Starting nfs-client"
sudo /usr/local/etc/init.d/nfs-client start 2> /dev/null
echo "Mounting $YOOPIES_PATH"
sudo mkdir -p $YOOPIES_PATH
sudo mount $VM_IP:$YOOPIES_PATH $YOOPIES_PATH -o noatime,soft,nolock,vers=3,udp,proto=udp,rsize=8192,wsize=8192,namlen=255,timeo=10,retrans=3,nfsvers=3
ls -al $YOOPIES_PATH
EOF
)

docker-machine ssh dev "echo '$content' | sudo tee $file && sudo chmod +x $file && sync" > /dev/null
