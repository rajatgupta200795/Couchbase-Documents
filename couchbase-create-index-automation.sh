sudo /opt/couchbase/bin/cbq --script="SELECT keyspace_id, name, index_key FROM system:indexes" --engine=http://localhost:8091 -u $1 -p $2  |  tail -n +6 > rough-index.json
for k in $(jq '.results | keys | .[]' rough-index.json); do
    value=$(jq -r ".results[$k]" rough-index.json);
    a=$(jq -r '.index_key' <<< "$value");
    b=$(jq -r '.keyspace_id' <<< "$value");
    c=$(jq -r '.name' <<< "$value");
#echo $a' '$b' '$c' '$k
if [ "$a" == '[]' ]; then
    if [ "$c" == '#primary' ]; then
        c=$b
    fi;
    echo 'create primary index `'$c'` on `'$b'` ' >> mid-index.txt
else
    echo 'create index `'$c'` on `'$b'` '$a >> mid-index.txt
fi;
done
rm -rf rough-index.json
sort -u mid-index.txt > index.txt
file_contents1=$(<index.txt)
echo "${file_contents1//\[/(}" > index.txt
file_contents2=$(<index.txt)
echo "${file_contents2//\]/)}" > index.txt
file_contents3=$(<index.txt)
echo "${file_contents3//\"/ }" > index.txt
rm -rf mid-index.txt

