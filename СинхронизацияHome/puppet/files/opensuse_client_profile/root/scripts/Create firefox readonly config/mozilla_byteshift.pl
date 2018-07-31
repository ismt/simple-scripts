#!/usr/bin/perl
# Byteshifting program for mozilla's netscape.cfg files
# Old netscape 4.x uses a bytechift of 7
# To decode: moz-byteshift.pl -s -7 <netscape.cfg >netscape.cfg.txt
# To encode: moz-byteshift.pl -s 7 <netscape.cfg.txt >netscape.cfg
# Mozilla uses a byteshift of 13
# To decode: moz-byteshift.pl -s -13 <mozilla.cfg >mozilla.txt
# To encode: moz-byteshift.pl -s 13 <mozilla.txt >mozilla.cfg

use strict;
use Getopt::Std;
use vars qw/$opt_s/;
getopts("s:");
die "Missing shift\n" if (!defined $opt_s);
my $buffer;
while(1) {
my $n=sysread STDIN, $buffer, 1;
last if ($n eq 0);
my $byte = unpack("c", $buffer);
$byte += 512 + $opt_s;
$buffer = pack("c", $byte);
syswrite STDOUT, $buffer, 1;
} 
