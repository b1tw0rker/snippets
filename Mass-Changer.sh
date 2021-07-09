#!/bin/bash
# Version 1.1 - Stand 03.06.2012

### vars
###
###
FOLDER=/tmp/changer



clear

if [ ! -d $FOLDER ]
 then
  mkdir $FOLDER
 fi



echo
while [ -z "$QUELLE" ]
do
        echo -n "Bitte absoluten Pfad der Quelle eingeben, ohne ending slash (QUIT fuer ENDE): "
        read QUELLE
        if [ $QUELLE = "QUIT" ] || [ $QUELLE = "quit" ] || [ $QUELLE = "Quit" ]
        then
           exit 1
        fi
        if [ ! -d $QUELLE ]
        then
                echo
                echo
                echo "$QUELLE ist kein Verzeichnis. Die Quelle muss ein Verzeichnis sein."
                echo
                exit 2
        fi
done
echo
while [ -z "$ALT" ]
do
        echo -n "Bitte alten Wert eingeben: "
        read ALT
done
echo
while [ -z "$NEU" ]
do
        echo -n "Bitte neuen Wert eingeben (Sonderzeichen mit Backslash (\): "
        read NEU
done
for  i in `grep -lr  $ALT $QUELLE`
do
        echo "DATEI $i wurde geaendert"
        DATEI=`basename $i`
        PFAD=`dirname $i`
        if [ -f $i ]
        then
                sed  s/$ALT/$NEU/g $i > $FOLDER/$DATEI
                mv $FOLDER/$DATEI $PFAD/$DATEI
        fi
done



while [ -z "$DELETE" ]
do

  echo -n "Temp Dir $FOLDER jetzt löschen ? (y/n): "
  read DELETE

  if [ $DELETE = "Y" ] || [ $DELETE = "y" ] 
        then
   if [ -d $FOLDER ]
    then
     rmdir $FOLDER
   fi
  fi

done


exit 0
