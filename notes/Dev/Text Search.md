# Text Search

```ini
--------------------
key1=val1
key2=val2
--------------------
```

Use the below command to search for ’thing I am looking for'

```sh
sed '/^---/ !{H;$ !d};x;/thing I am looking for/ !d'
```

```sh
cat service_log.2018-08-07-* | gsed '/^---/ !{H;$ !d};x;/Error=1/ !d' | fgrep "RequestId=" | awk -F"=" '{print $NF}' | sort -u
```

```sh
tail -f service_log.* | sed '/^---/ !{H;$ !d};x;/[(Fault)\|(Error)]=1/ !d'
```

## Tags
grep, sed, logs, posix