#!/usr/bin/perl
use DBI;
use DBD::mysql;

### Username and password
###
###
$username  = "root";
$password  = "PASSWORD";
$pfadzonen = "/var/named/chroot/var/named/master/"; # absoluter pfad zu den Zonen - requires ending slash
$namedconf = "/var/named/chroot/etc/"; # absoluter pfad zur Zonendatei - requires ending slash
$zonefile  = "named.rfc1912.zones";
$testmode  = "2";

### some zonen values
###
###
$ttl = "38400";

#############################################################################################

### Database connection to mysql
###
###
if ($testmode ne "1") {
  $dsn = 'dbi:mysql:dns:localhost:3306';
  $dbh = DBI->connect($dsn, $username, $password) or die "Cant connect to the DB: $DBI::errstr\n";

  $query = "truncate table zonenrecords";
  $sth = $dbh->prepare($query);
  $sth->execute();
}


 ###open and close named.conf
 ###
 ###
 open (named, "$namedconf$zonefile" ) || die "cannot open $zonefile for reading";
 @stuff = <named>;
 close(named);


### unsetting is needed !!!
###
###
$zone = "";


foreach $line (@stuff) {
  $dbfile = "";
  if ($line =~ m/^zone/i) {

    @container = split ("\"", $line);
	$z = "db.$container[1]";
	$domainname = $container[1];
    

     if ($z ne "") {
      $dbfile = "$pfadzonen$z";
	  # print "$no - $dbfile\n";
     }

 }

 if($dbfile ne "" && -e $dbfile ) {
  my(%types,%data);
   if ($testmode eq "1") {
	 #print "dbfile = $dbfile\n";
   }

 open (dbfile1, $dbfile) || print "cannot open $dbfile for reading";
 @dblines = <dbfile1>;
 close (dbfile1);
 foreach $line1 (@dblines) {
 chomp($line1);

 # getting SOA Data
 if ($line1 =~ m/SOA/i) {
  my($junk, $junk, $soa, $primary_ns, $resp_person, $junk) = split(/\s+/, $line1);

   if ($testmode eq "1") {
    #print "dbfile is: $dbfile SOA is: $soa primaryns is: $primary_ns resp contact is: $resp_person\n";
   }

 
   if ($testmode eq "1") {
	print "domainname: $domainname\nZonefile: $z - serial: $serial\n";
	#print "\n";
   }
    

    ## insert the SOA
	if ($soa ne "" && $testmode ne "1") {
	 # manuell setting
     $serial = "2013112301";

	 $query = "INSERT INTO zonenrecords (zone,     ttl,    type,   host, primary_ns, resp_contact, serial, refresh, retry, expire, minimum) VALUES
                                        ('$domainname', '$ttl', 'SOA',    'ns1.provider4u.de.' , '$primary_ns', '$resp_person' , '$serial' , '10800' , '3600' , '604800', '38400' )";
	 $sth = $dbh->prepare($query);
     $sth->execute();
    }


 #Found soa, find serial for this bitch
 $dbfile3 = $dbfile;
 open (dbfile3, $dbfile) || print "cannot open $dbfile3 for reading";
 @dblines3 = <dbfile3>;
 close (dbfile3);
 $nr=1;
 $nrs=1;
 foreach $zline (@dblines3) {
  $mx      = "";
  $a       = "";
  $arecord = "";
  $ip      = "";
  chomp($zline);

  if($zline =~ m/IN/i && $nr > 2) {
   
   $zeile = $zline;
   $zeile =~ tr/ /;/s;
   $zeile =~ s/^\s+//;  ## trim start
   $zeile =~ s/\s+$//;  ## trim end
   ## replace the MX;1 prob
   $zeile =~ s/MX;1/MX 1/g;
   
   if ($zeile =~ m/MX 1/i) {
	   @mx = split (";", $zeile);
	   $mx = $mx[3];
   }


   if ($zeile =~ m/IN;A/i) {
	   @a = split (";", $zeile);
	   $a = $a[0];
	   $ip = $a[3];

       #build $arecord from $a
	   if ($a ne "") {
		@rec = split(/\./,$a);
        $arecord = $rec[0];
	   }

	   #sonderfall domain self in a
       @tmpdom = split(/\./,$domainname);
	   if ($arecord eq $tmpdom[0]) {
		   $arecord = "@";
	   }

   }




    # print "$nr - $zeile - $mx\n";
    # print "$a - $record[0]\n";
 

    ## insert the NS Infos
	if ($soa ne "" && $testmode ne "1" && $nrs eq "1") {

	  $query = "INSERT INTO zonenrecords (zone,          ttl,    type,   host,   data ) VALUES
                                       ('$domainname', '$ttl' ,  'NS',    '\@' , 'ns1.provider4u.de.' )";
	  $sth = $dbh->prepare($query);
      $sth->execute();



	  $query = "INSERT INTO zonenrecords (zone,          ttl,    type,   host,         data ) VALUES
                                       ('$domainname', '$ttl' ,  'NS',    '\@' , 'ns2.provider4u.de.' )";
	  $sth = $dbh->prepare($query);
      $sth->execute();

      $nrs = 0;
    }



     if ($mx ne "") {
	  $query = "INSERT INTO zonenrecords (zone,          ttl,    type,   host, mx_priority,        data ) VALUES
                                       ('$domainname', '$ttl' ,  'MX',    '\@' , '1',             '$mx' )";
	  $sth = $dbh->prepare($query);
      $sth->execute();
	  $mx = "";
     }

     if ($arecord ne "") {
	  $query = "INSERT INTO zonenrecords (zone,          ttl,    type,     host,           data ) VALUES
                                       ('$domainname', '$ttl' ,  'A',    '$arecord' ,      '$ip' )";
	  $sth = $dbh->prepare($query);
      $sth->execute();
     }



  }
 $nr++;
 }
 #print "========================================================================\n";

   } 
  }
 }
 $no++;
}





 if ($testmode ne "1") {
  $dbh->disconnect();
 }


exit;
