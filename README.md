# snippets

# drop all MySQL databases

```bash
mysql -p<DEINPASSWORT> -e "show databases" | grep -v Database | grep -v mysql | grep -v information_schema | gawk '{print "drop database " $1 ";select sleep(0.1);"}' | mysql -p<DEINPASSWORT>
```


### License
[MIT](https://choosealicense.com/licenses/mit/)
