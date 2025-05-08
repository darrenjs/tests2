#!/usr/bin/env perl

# Simple perl script to lauch emacsclient

use strict;
use warnings;

foreach  my $input ( @ARGV )
{
    my $FILE;
    my $LINE="";

    if ($input =~ m/^([^:]*):(\d+):.*/)
    {
        print "rule1";
        $FILE=$1;
        $LINE="+$2";
    }
    elsif ($input =~ m/^([^:]*):(\d+).*/ )
    {
        $FILE=$1;
        $LINE="+$2";
    }
    elsif ($input =~ m/^([^:]*):$/ )
    {
        $FILE=$1;
    }
    else
    {
        $FILE=$input
    }

    # Check the file exists
    if ( -e "$FILE" ||  -d  "$FILE" )
    {
        my $CMD="emacsclient --no-wait $LINE \"$FILE\"";
        system ($CMD);
    }
    else
    {
        print "file not found: $FILE\n";
    }
}
