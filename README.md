# linux snippets

### drop all MySQL databases

```bash
mysql -p<DEINPASSWORT> -e "show databases" | grep -v Database | grep -v mysql | grep -v information_schema | gawk '{print "drop database " $1 ";select sleep(0.1);"}' | mysql -p<DEINPASSWORT>
```


### find - practical regex examples

```bash
find . -iname 'wthm*g.php' -type f -exec echo {} \;
find . -iname 'wthm*g.php' -type f -exec rm -f {} \;  # find & remove!

find . -iname 'pageinfo.php' -type f -exec echo {} \;
find . -iname 'pageinfo.php' -type f -exec rm -f {} \;  # find & remove!

find . -iname '*[0-9]*.php' -type f -exec echo {} \;
```

### connected ports

```bash
lsof -i TCP -n -P | awk '/ESTABLISHED/ {print $1"/"$3"/"$8}' | sort -u
```

### Monitoring connected ports

```bash
#!/bin/bash
i=1

while [ "$i" == 1 ] ; do

 clear
 lsof -i TCP -n -P | awk '/ESTABLISHED/ {print $1"/"$3"/"$8}' | sort -u
 sleep 5

done

exit 0
```


### cd to previous folder

```bash
cd -
```











### License
[MIT](https://choosealicense.com/licenses/mit/)
