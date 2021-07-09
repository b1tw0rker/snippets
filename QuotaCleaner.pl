#!/usr/bin/perl
# (c) 2011-2021 by BitWorker, Nick Herrmann
# version 1.2


$device="/dev/md0";
system ("clear");


########################################################
# Some Input
########################################################
print "Gib die Quotabeginn UserID ein: ";
my $startquota = <STDIN>;

print "Gib die Quotaend UserID ein: ";
my $endquota = <STDIN>;


chomp $startquota;
chomp $enduota;

########################################################
# Failover for endquota
########################################################
if ($endquota eq "") {
 $endquota=$startquota;
}

########################################################
# do the action
########################################################
if ($startquota ne "" && $endquota ne "") {
 for($i = $startquota; $i <= $endquota; $i++) {

  system ("setquota -u $i 0 0 0 0 $device");

  print "cleaned $i\n";


  if ($i eq $endquota) {
   last;
  }
 }
}



########################################################
# Restart?
########################################################
print "Go Ahead? (y/n) ";
# Eine Zeile einlesen
my $start = <STDIN>;
chomp $start;

if ($start eq "y") {
 system ("clear");
 system ("/path/to/script/QuotaCleaner.pl");
}



exit 0;
