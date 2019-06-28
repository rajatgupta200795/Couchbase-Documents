sudo /opt/couchbase/bin/cbq --script="SELECT condition, keyspace_id, name, index_key FROM system:indexes order by keyspace_id ASC" --engine=http://localhost:8091 -u $1 -p $2  |  tail -n +6 > rough-index.json
for k in $(jq '.results | keys | .[]' rough-index.json); do
    value=$(jq -r ".results[$k]" rough-index.json);
    a=$(jq -r '.index_key' <<< "$value");
    b=$(jq -r '.keyspace_id' <<< "$value");
    c=$(jq -r '.name' <<< "$value");
    d=$(jq -r '.condition' <<< "$value");
b=${b//\[/(}
b=${b//\]/)}
c=${c//\[/(}
c=${c//\]/)}
#echo  $a' '$b' '$c' '$d
if [ "$a" == '[]' ]; then
    if [ "$c" == '#primary' ]; then
        c=$b
    fi;
    echo 'create primary index `'$c'` on `'$b'` ' >> mid-index.txt
else
    a=${a//\"/}
    a=${a//\[/(}
    a=${a//\]/)}
    if [ "$d" == null ]; then
        echo 'create index `'$c'` on `'$b'` '$a >> mid-index.txt
    else
        echo 'create index `'$c'` on `'$b'` '$a' where '$d' ' >> mid-index.txt
    fi;
fi;
done
rm -rf rough-index.json
mv mid-index.txt index.txt
#sort -u mid-index.txt > index.txt
rm -rf mid-index.txt
sed "s/(0)/[0]/g;s/(1)/[1]/g;s/(2)/[2]/g" index.txt>new-index.txt
rm -rf index.txt
mv new-index.txt index.txt
rm -rf new-index.txt
