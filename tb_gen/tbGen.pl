#!/usr/bin/perl
#####################################################################
# File Name   : tb_gen
# Description : Generates system verilog instance template and 
#               sample tb. Supports prefix, postfix and word wrap.
# Dependency  : PERL v5.16.3 or higher
# Author      : Vinayaka Suresh
#
#####################################################################

use strict;
use warnings;
use Getopt::Long;
use File::Find;

# Options - replace with getOpt
my $pre           = "";
my $post          = "";
my $wrapLen       = 10;
my $debug         = undef;
my $gentb         = undef;
my $instGen       = undef;
my $paramList     = undef;
my $fname         = undef;
my $autoInp       = 1;

GetOptions ("pre=s"          => \$pre,
            "post=s"         => \$post,
            "wlen=i"         => \$wrapLen,
            "f=s"            => \$fname,
            "gentb"          => \$gentb,
            "instGen"        => \$instGen,
            "paramList"      => \$paramList,
            "d"              => \$debug,
            "autoinp"        => \$autoInp)
or die("Error in command line arguments\n");

# System verilog file to read
my $fh;
open $fh,'<',$fname or die "Cant open file $fname. \n $!";

# Temp file - comments removed
my $fw;
my $fwname="${fname}_temp";
open $fw,'>',$fwname or die "Cant open file $fname. \n $!";

#Remove comments
select $fw;
foreach my $line (<$fh>) {
  chomp $line;
  $line =~ s/\/\/.*$//;
  print "$line \n";
}

# close file handles
select STDOUT;
close $fh;
close $fw;

# Read modified files
# $fwname="$ARGV[0]_temp";
open $fw,'<',$fwname or die "Cant open file $fname. \n $!";

# Array declarations
my $moduleName;
my @paramArray;
my @portArray;
my @paramName;
my @portName;
my @iportList;
my @oportList;
my @ioportList;
my @clkList;
my @rstList;

# Variable declarations
my $inst;
my $inst_len=0;
my $param_len=0;
my $decl = "";
my $type;

###############################################################################
# Extract param and port list from file
###############################################################################
local $/=");";
my $line = <$fw>;
chomp $line;
$line =~ s/\/\*(?:(?!\*\/).)*\*\/\n?//sg;
$line =~ /^.*?module[\s\n\r]*(?<modName>\w+)[\s\n\r]*(?:#\((?<refParamName>.*?)\)[\s\n\r]*)?\((?<refPortName>.*)/smg;

# Module name
print "CAP:: Module    = $+{modName} \n" if (defined($debug));
$moduleName = $+{modName};
$inst = "$moduleName ";

###############################################################################
# Param processing
###############################################################################
if (defined($+{refParamName})){
  print "CAP:: refParamName = $+{refParamName} \n" if (defined($debug));
  if(defined($paramList)) {
    my $paramList = $+{refParamName};
    my @paramListArr = split /,/,$paramList;
    foreach my $pline (@paramListArr) {
      chomp $pline;
      $pline =~ s/[\n\r]//g;
      next if ($pline =~ m/^\s*$/);
      next if ($pline =~ m/^\s*\/\//);
      next if ($pline =~ m/^(parameter)/);
      $pline =~ s/^(\s*parameter\s+int\s+)(\w+\s*=.*)/$1 unsigned $2/;
      print "$pline,\n";
    }
    exit;
  }
  $inst .= "#( \n  ";
  @paramArray = split /parameter\s*/,$+{refParamName};
  foreach my $param (@paramArray) {
    chomp $param;
    $param =~ s/^.*(?<pname>\b\w+)\s*=\s*(?<pval>\w+),?/.$+{pname}($+{pname}),/;
    if (defined($+{pname})) {
      my $param_len_temp = length($param);
      if($param_len + $param_len_temp > $wrapLen) {
        $param_len = $param_len_temp;
        $inst .= "\n  .$+{pname} ($+{pname}),";
      } else {
        $param_len += $param_len_temp;
        $inst .= ".$+{pname} ($+{pname}), ";
      }
    }
  }
  $inst =~ s/,\s*$/)\n/;
}

###############################################################################
# Port processing
###############################################################################
print "CAP:: port Name = $+{refPortName} \n" if (defined($debug)); 
@portArray  = split /,/,$+{refPortName};
$inst .= "u_$pre$moduleName$post\n  (\n  ";
foreach my $port (@portArray) {
  $port =~ s/^\s*(?<dir>(?:\w+))\s+(?<type>(?:[\w:]+))?\s*(?<vec>\[.*?\])?\s*(?<port>\b\w+)\s*(?<arr>\[.*?\])?\s*,?//;
  if (defined($debug)) {
    print "\nPORT DES: \n";
    print "DIR  = $+{dir} \n";
    print "TYPE = $+{type} \n" if(defined($+{type}));
    print "VEC  = $+{vec} \n" if(defined($+{vec}));
    print "PORT = $+{port} \n";
    print "ARR  = $+{arr} \n" if(defined($+{arr}));
  }

  if($+{dir} eq "input") {
    my $lport = "$+{port}"; 
    push @iportList,$lport;
    if($lport =~ /clk|clock/) {
      push @clkList,$lport;
    }
    elsif($lport =~ /(\brst|\breset)/) {
      push @rstList,$lport;
    }
  }
  elsif ($+{dir} eq "output"){
    push @oportList,$+{port};
  }
  elsif ($+{dir} eq "inout"){
    push @ioportList,$+{port};
  } 

  # List out declarations
  if (defined($+{type})) {
    $type = "$+{type} ";
  }
  else {
    $type = "logic ";
  }
  $decl .= "$type ";
  $decl .= "$+{vec} " if(defined($+{vec}));
  $decl .= "$pre$+{port}$post";
  $decl .= " $+{arr} " if(defined($+{arr}));
  $decl .= ";\n";

  # Add ports to instance list
  my $inst_temp     = ".$+{port} ($pre$+{port}$post), ";
  my $inst_temp_len = length($inst_temp);
  if($inst_len + $inst_temp_len > $wrapLen) {
    $inst_len = $inst_temp_len;
    $inst    .= "\n  $inst_temp";
  } else {
    $inst_len += $inst_temp_len;
    $inst     .= "$inst_temp";
  }
}
$inst =~ s/,\s*$/);\n/;

$/="\n";

if($autoInp == 0) {	
	print "\nList of possible clocks:\n @clkList \n";
	print "\nPlease confirm by space separated list: e.g. clk1 clk2\n";
	my $clkListUsr;
	$clkListUsr = <STDIN>;
	@clkList = split /\s/,$clkListUsr;
}
for (my $i=0; $i<$#iportList; $i++){
  foreach my $ports (@clkList){
    splice @iportList,$i,1 if ($ports eq $iportList[$i]);
  }
}

if($autoInp == 0) {	
	print "\nList of possible resets:\n @rstList \n";
	print "\nPlease confirm by space separated list: e.g.: rst1 rst2\n";
	my $rstListUsr;
	$rstListUsr = <STDIN>;
	@rstList = split /\s/,$rstListUsr;
}
for (my $i=0; $i<$#iportList; $i++){
  foreach my $ports (@rstList){
    splice @iportList,$i,1 if ($ports eq $iportList[$i]);
  }
}


close $fh;
###############################################################################
# Print result
###############################################################################
print "// Declaration: \n$decl \n" if (defined($debug));
print "// Instance: \n$inst \n" if (defined($debug));
close $fh;
system("rm -rf $fwname") unless (defined($debug));

if (defined ($instGen)) {
  print "\n$inst\n";
}

if (defined($gentb)) {
  my $iclkgen  = "";
  my $iclkinit = "";
  my $irstgen  = "";
  my $irstinit = "";
  $fwname="tb_${moduleName}.sv";
  open $fw,'>',$fwname or die "Cant open file $fname. \n $!";

  print {$fw} "module tb_${moduleName};\n";
  print {$fw} "\n$decl\n";
  print {$fw} "\n$inst\n";

  # Assign a default clock - need to be modified
  foreach my $line (@clkList){
    $iclkinit .="\t$line = '0;\n";
    $iclkgen  .="\n\tbegin\n";
    $iclkgen  .="\t\tforever\n";
    $iclkgen  .="\t\t\t$line = #5 ~$line;\n";
    $iclkgen  .="\tend\n";
  }
  # Assign a default active low reset
  foreach my $line (@rstList){
    $irstinit ="\t$line = 1'b0;\n";
    $irstgen  .="\n\tbegin\n";
    $irstgen .= "\t\t$line = 1'b0;\n";
    $irstgen .= "\t\t$line = #100 1'b1;\n";
    $irstgen  .="\tend\n";
  }

  my $tb_str = <<TB_STR;

initial
begin
  $iclkinit
  $irstinit
  fork
    $iclkgen
    $irstgen
    begin : timeout
      \$display ("Starting simulation");
      #10000000;
      \$display ("Timeout period elapsed. Ending test");
      \$finish;
    end
  join
end

TB_STR
  print {$fw} "$tb_str\n";

  print {$fw} "initial\nbegin\n";
  foreach my $line (@iportList){
    print {$fw} "  $line = '0;\n";
  }
  print {$fw} "#100;\n";
  print {$fw} "end\n";

  print {$fw} "endmodule";
  close $fw;
}
