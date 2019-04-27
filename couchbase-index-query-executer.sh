while IFS=, read -r input; do
    sudo /opt/couchbase/bin/cbq --script="$input" --engine=http://localhost:8091 -u $1 -p $2
done < index.txt

