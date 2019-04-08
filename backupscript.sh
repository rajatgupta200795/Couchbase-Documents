if [ -d "backup" ]; then
   echo ""
else
   sudo mkdir /mnt/datadisk/backup
   sudo chmod 777 /mnt/datadisk/backup
fi
cd /opt/couchbase/bin/
u=Administrator
p=password
./cbbackup http://127.0.0.1:8091 /mnt/datadisk/backup/ -u $u -p $p
head1=$(ls -t /mnt/datadisk/backup | head -1)
cd /mnt/datadisk/backup/$head1
head2=$(ls -t /mnt/datadisk/backup/$head1 | head -1)
name="any-cluster-name-for-folder"
name=$name-`date +%d-%m-%y`.zip
zip -r -m $name $head2
aws s3 cp $name s3://folder-name/
rm $name
cd ..i
rm -r $head1
