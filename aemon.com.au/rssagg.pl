#!/usr/bin/env perl

use strict;
use warnings;

use Date::Parse;
use XML::RSS;
use LWP::Simple;
use HTML::TreeBuilder;

binmode STDOUT, ":utf8";

my $urlFile = "urls";
my $outputFile = "rss.html";
my $cutOffDate;
     
print "\nAggregating RSS feeds...\n";

open FH, "<$urlFile" || die "File not found\n"; 
binmode FH, ":utf8";
my @feeds = <FH>; 
close FH;

if (-e $outputFile){
   unlink($outputFile);
} 

outputAsHtml(dateFilter(sortFeeds(combineFeeds(@feeds)))); 

sub convertDate{
   my ($day, $month, $year) = split(/\//, $_[0]);
   if($day < 0 || $day > 31){
      showUsage("Not a real day!");
   }
   else{
      SWITCH: {
         if($month == '01'){ $month = "JAN"; last SWITCH;}
         if($month == '02'){ $month = "FEB"; last SWITCH;}
         if($month == '03'){ $month = "MAR"; last SWITCH;}
         if($month == '04'){ $month = "APR"; last SWITCH;}
         if($month == '05'){ $month = "MAY"; last SWITCH;}
         if($month == '06'){ $month = "JUN"; last SWITCH;}
         if($month == '07'){ $month = "JUL"; last SWITCH;}
         if($month == '08'){ $month = "AUG"; last SWITCH;}
         if($month == '09'){ $month = "SEP"; last SWITCH;}
         if($month == '10'){ $month = "OCT"; last SWITCH;}
         if($month == '11'){ $month = "NOV"; last SWITCH;}
         if($month == '12'){ $month = "DEC"; last SWITCH;} 
         showUsage("Not a real month!");  
      }
   }
   return my $date = $day." ".$month." ".$year;
}

sub combineFeeds{
   my @combinedfeed;
   my $rss = XML::RSS->new(version => '2.0');
   foreach my $url(@_){
      if (head($url)){
         print "Fetching feed from :: $url";
         my $feed = get($url);
         print "Verifying url :: $url";
         if (!($feed =~ /<rss.*version="\d.\d"/)){
            chomp $url;
            die "$url does not contain a valid rss feed!\n"
         }
         else{
            $rss->parse($feed);
            print "Parsing feed...\n";
            my @parsedFeed = @{$rss->{'items'}};
            print "Combining feed...\n";
            push @combinedfeed, @parsedFeed;
         }
      }
      else{
         die "Trouble connectiong to $url\n"
      }
   }
   return @combinedfeed;
}

sub sortFeeds{
   print "\nSorting feeds...";
   my @sortedFeed = sort { 
   
   if ($a->{'pubDate'} eq '') { $a->{'pubDate'} = localtime() . " +1000"; }
   if ($b->{'pubDate'} eq '') { $b->{'pubDate'} = localtime() . " +1000"; }
   
   $a->{'pubDate'} = localtime(str2time($a->{'pubDate'})) . " +1000";
   $b->{'pubDate'} = localtime(str2time($b->{'pubDate'})) . " +1000";
   
   my ($ass,$amm,$ahh,$aday,$amonth,$ayear) = strptime($a->{'pubDate'});
   my ($bss,$bmm,$bhh,$bday,$bmonth,$byear) = strptime($b->{'pubDate'});

   if($aday < 10){
      $aday = "0".$aday;
   }
   if($bday < 10){
      $bday = "0".$bday;
   }
   
   my $c = $ayear . $amonth . $aday . $ahh . $amm . $ass;
   my $d = $byear . $bmonth . $bday . $bhh . $bmm . $bss;
   
   $d <=> $c;
   } @_;
   
   return @sortedFeed;  
}

sub dateFilter{
   print "\nApplying date filter...";
   my @dateFiltered;
   if (defined($cutOffDate)){
      foreach my $item(@_){
         my ($ss,$mm,$hh,$day,$month,$year) = strptime($item->{'pubDate'});
         if($day < 10){
            $day = "0".$day;
         }
         my $itemDate = $year . $month . $day . $hh . $mm . $ss;
         if ($itemDate > $cutOffDate){
            push @dateFiltered, $item;
         }
      }
      return @dateFiltered
   }
   return @_;
}

sub genOutput{
   my $item = $_[0];
   my $title;
   my $author;
   my $creator;
   my $pubDate;
   my $description;
   my $guid;
   
   if (defined($item->{'title'})){
      $title = $item->{'title'};
   }
   if (defined($item->{'author'})){
      $author = $item->{'author'};
   }
   else{
      if (defined($item->{'dc'}->{'creator'})){
         $creator = $item->{'dc'}->{'creator'};
      }           
   }
   if (defined($item->{'pubDate'})){
      $pubDate = $item->{'pubDate'};
   }
   if (defined($item->{'description'})){
      $description = $item->{'description'};
   }
   if (defined($item->{'guid'})){
      $guid = $item->{'guid'};
   } 

   return $title, $author, $creator, $pubDate, $description, $guid;
}

sub outputAsHtml{
print (
"<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!-- doctype declaration -->
<!DOCTYPE html PUBLIC \"-\/\/W3C\/\/DTD XHTML 1.0 Strict\/\/EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http:\/\/www.w3.org\/1999\/xhtml\" xml:lang=\"en\" lang=\"en\">
   <head>
      <title>My Rss Feed</title>
      <style type=\"text\/css\">
         div.top {
            background-color:#8FBC8F;
            padding:10px;
            border-bottom:2px solid #2E2E2E;}
         div.top h1 {
            font-family: arial, verdana, serif;
            font-size:20px;
            color:#000000;
            margin: 5px;}
         div.top p {
            font-size:11px;
            margin:5px}
         div.feed h1 {
            padding-top:10px;
            font-print "\nOutputting rss as html...\n";
open hFH, ">>$outputFile" || die "Could not open file\n";family: Times;
            color:#000000;
            margin-left:40px;
            text-align:left;
            font-size:14pt}
         div.feed h2 {
            color:#2E2E2E;
            margin-left:40px;
            text-align:left;
            font-size:10pt}  
         div.item {
            background-color:#EEF3E2;}
         div.content {
            font-size:10pt;
            margin-left:60px;
         max-width: 60%}
         div.content p {
            padding-bottom: 5px}
         div.content a {
            color:#000000}
      </stylprint "\nOutputting rss as html...\n";
open hFH, ">>$outputFile" || die "Could not open file\n";e>
   </head>
   <body>
      <div class=\"top\">
         <h1>RSS Aggregator</h1>
         <p>aggregating my feeds!</p>
      </div>
      <div class=\"feed\">");
   
   foreach my $item(@_){
      my ($title, $author, $creator, $pubDate, $description, $guid) = genOutput($item);
      
      printf ("
         <div class=\"item\">
            <h1>%s</h1>", $title);
      if (defined($author)){            
         printf ("
            <h2>Author:%s</h2>", $author);
      }     
      if (defined($creator)){            
         printf ("
            <h2>Creator: %s</h2>", $creator);
      } 
      printf ("
            <h2>Date Published: %s</h2>
            <div class=\"content\">
               %s", $pubDate, $description);
      if (defined($guid)){            
         printf hFH ("
               <p><em>full article <a href=\"%s\">here</a> ...</em></p>", $guid);
      }
      print ("
              </em></strong></a>
            </div>
         </div>");
   }
  
print ("
      </div>
   </body>
</html>");
}