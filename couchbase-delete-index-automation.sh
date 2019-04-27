sudo /opt/couchbase/bin/cbq --script="SELECT keyspace_id, name, index_key FROM system:indexes" --engine=http://localhost:8091 -u $1 -p $2 |  tail -n +6 > rough-index.json
for k in $(jq '.results | keys | .[]' rough-index.json); do
    value=$(jq -r ".results[$k]" rough-index.json);
    a=$(jq -r '.index_key' <<< "$value");
    b=$(jq -r '.keyspace_id' <<< "$value");
    c=$(jq -r '.name' <<< "$value");
#echo $a' '$b' '$c' '$k
if [ "$a" == '[]' ]; then
    if [ "$c" == '#primary' ]; then
        c=$c
    fi;
    echo 'drop index `'$b'`.`'$c'`' >> mid-index.txt
else
    echo 'drop index `'$b'`.`'$c'`' >> mid-index.txt
fi;
done
rm -rf rough-index.json
sort -u mid-index.txt > index.txt
file_contents=$(<index.txt)
echo "${file_contents//[/(}" > index.txt
file_contents=$(<index.txt)
echo "${file_contents//]/)}" > index.txt
rm -rf mid-index.txt

