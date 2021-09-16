#!/usr/bin/perl
#####################################################################
# File Name   : rtlInteg
# Description : Generates system verilog wrapper with signal
#               naming, regex matching
# Dependency  : PERL v5.16.3 or higher
# Author      : Vinayaka Suresh
#
#####################################################################
use Storable qw(dclone);
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

our %mhash;
our %hash;
our %decl;
our %top;
our %topParams;
my @flist;
my $debug      = undef;
my $fconf      = undef;
my $moduleName = undef;
my $instName   = undef;

# Parse user arguments
GetOptions ("f=s"      => \$fconf,
            "d"        => \$debug)
or die("Error in command line arguments\n");

my $fr;
open $fr,'<',$fconf or die "Cant open file $fconf. $!";

###############################################################################
# Parsing configuration file to list modules
###############################################################################
foreach my $line (<$fr>){
  chomp $line;
  next if ($line =~ m/^\s*$/);

  if ($line =~ m/^\s*endtop\s*$/){
    $moduleName = undef;
  }

  if (defined($moduleName)) {
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    my ($port,$dir) = split /\s+/,$line;
    $top{$port} = ${dir};
  }

  if ($line =~ m/^\s*top\s+(\w+)\s*$/){
    $moduleName = $1;
    $top{TOPMODULE} = $moduleName;
  }

  if ($line =~ m/^\s*module\s+(\w+)\s+(\w+)\s*$/){
    my $fileName = "$1".".sv";
    push @flist,"$fileName";
  }
}
$moduleName = undef;

###############################################################################
# Preprocess RTL files
###############################################################################
foreach my $fname (@flist) {
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
    
    ###############################################################################
    # Extract port and parameters
    ###############################################################################
    # Read modified files
    open $fw,'<',$fwname or die "Cant open file $fname. \n $!";
    
    # Array declarations
    my @paramArray;
    my @portArray;
    # Variable declarations
    my $type;
    
    local $/=");";
    my $line = <$fw>;
    chomp $line;
    $line =~ /^.*?module[\s\n\r]*(?<modName>\w+)[\s\n\r]*(?:#\((?<refParamName>.*?)\)[\s\n\r]*)?\((?<refPortName>.*)/smg;
    
    # Module name
    $moduleName = $+{modName};
    $mhash{MODULES}{$moduleName} = undef;
    ###############################################################################
    # Param processing
    ###############################################################################
    if (defined($+{refParamName})){
      @paramArray = split /parameter\s*/,$+{refParamName};
      foreach my $param (@paramArray) {
        chomp $param;
        $param =~ m/^.*(?<pname>\b\w+)\s*=\s*(?<pval>\w+),?/;
        if (defined($+{pname})) {
          $mhash{$moduleName}{"PARAM"}{$+{pname}} = $+{pval};
        }
      }
    }
    
    ###############################################################################
    # Port processing
    ###############################################################################
    @portArray  = split /,/,$+{refPortName};
    foreach my $port (@portArray) {
      $port =~ s/^\s*(?<dir>(?:\w+))\s+(?<type>(?:\w+))?\s*(?<vec>\[.*?\])?\s*(?<port>\b\w+)\s*(?<arr>\[.*?\])?,?//;
    
      # List out declarations
      if (defined($+{type})) {
        $type = "$+{type} ";
      }
      else {
        $type = "logic ";
      }
    
      my $lport = "$+{port}"; 
      $mhash{$moduleName}{"PORT"}{$lport}{dir}  = $+{dir};
      $mhash{$moduleName}{"PORT"}{$lport}{type} = ${type};
      $mhash{$moduleName}{"PORT"}{$lport}{vec}  = $+{vec};
      $mhash{$moduleName}{"PORT"}{$lport}{arr}  = $+{arr};
      $mhash{$moduleName}{"PORT"}{$lport}{sig}  = ${lport};
    }
    close $fh;
  system("rm -rf $fwname");
}
###############################################################################
# RTL integration configuration
###############################################################################
seek $fr,0,0;

$moduleName = undef;
$instName   = undef;

foreach my $line (<$fr>){
  chomp $line;
  next if ($line =~ m/^\s*$/);
  if ($line =~ m/^\s*endmodule\s*$/){
    $moduleName = undef;
    $instName   = undef;
  }

  if (defined($moduleName)) {
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    my ($sso,$rso) = split /\s+/,$line; 
    foreach my $tsig (keys $hash{$moduleName}{"PORT"}){
      my $sig = $hash{$moduleName}{"PORT"}{$tsig}{"sig"};
      my $sig_orig = $sig;
      my $ss = $sso;
      my $rs = $rso;
      #print "1:: TSIG = $tsig \tSIG = $sig\tSS = $ss\tRS = $rs\n";
      if ($sig =~ m/$ss/){
        my $m1 = $1 ;
        my $m2 = $2 ;
        my $m3 = $3 ;
        my $m4 = $4 ;
        my $m5 = $5 ;
        my $m6 = $6 ;
        my $m7 = $7 ;
        my $m8 = $8 ;
        my $m9 = $9 ;
        $rs =~ s/\$1/$m1/g;
        $rs =~ s/\$2/$m2/g;
        $rs =~ s/\$3/$m3/g;
        $rs =~ s/\$4/$m4/g;
        $rs =~ s/\$5/$m5/g;
        $rs =~ s/\$6/$m6/g;
        $rs =~ s/\$7/$m7/g;
        $rs =~ s/\$8/$m6/g;
        $rs =~ s/\$9/$m9/g;
        #print "2:: TSIG = $tsig \tSIG = $sig\tSS = $ss\tRS = $rs\n";
        $sig = $rs;
      }
      $hash{$moduleName}{"PORT"}{$tsig}{sig} = $sig;
    }
  }
  if ($line =~ m/^\s*module\s+(\w+)\s+(\w+)\s*$/){
    my $omoduleName = $1;
    my $oinstName   = $2;
    $moduleName = "$1#$2";
    $hash{MODULES}{$moduleName} = $oinstName;
    $hash{$moduleName} = dclone ($mhash{$omoduleName});
  }

}
close $fr;

###############################################################################
# Extract declarations 
###############################################################################
foreach my $mods (keys $hash{MODULES}) {
  foreach my $ports (keys $hash{$mods}{"PORT"}){
    my $sig = $hash{$mods}{"PORT"}{$ports}{"sig"};
    if (exists $decl{$sig}) {
      if (defined $decl{$sig}{vec} && defined $hash{$mods}{"PORT"}{$ports}{vec}) {
        print "-E-: Error: Vector width didn't match\n" unless ($decl{$sig}{vec}  eq $hash{$mods}{"PORT"}{$ports}{vec});
      }
      print "-E-: Error: Type didn't match\n" unless ($decl{$sig}{type} eq $hash{$mods}{"PORT"}{$ports}{type});
      if (defined $decl{$sig}{arr}  && defined $hash{$mods}{"PORT"}{$ports}{arr}) {
        print "-E-: Error: Array width didn't match\n" unless ($decl{$sig}{arr}  eq $hash{$mods}{"PORT"}{$ports}{arr});
      }

      unless ($decl{$sig}{dir} eq $hash{$mods}{"PORT"}{$ports}{dir}) {
        if(exists $top{$sig}) {
          $decl{$sig}{int}  = 0;
          $decl{$sig}{auto} = 0;
        } else {
          $decl{$sig}{int} = 1;
          $decl{$sig}{auto} = 1;
        }
      }

    } else {
      $decl{$sig}{dir}  = $hash{$mods}{"PORT"}{$ports}{dir};
      $decl{$sig}{vec}  = $hash{$mods}{"PORT"}{$ports}{vec};
      $decl{$sig}{type} = $hash{$mods}{"PORT"}{$ports}{type};
      $decl{$sig}{arr}  = $hash{$mods}{"PORT"}{$ports}{arr};
      $decl{$sig}{int}  = 0;
      if(exists $top{$sig}) {
        $decl{$sig}{auto} = 0;
      } else {
        $decl{$sig}{auto} = 1;
      }
    }
  }
}

###############################################################################
# Generate port list and declarations
###############################################################################

my $io_ports="";
my $io_ports_auto="";
my $io_ports_conf="";
my $local_sig="";
my $inst="";

foreach my $node (keys %decl){
  if ($decl{$node}{"int"} == 1) {
    $local_sig .= "$decl{$node}{'type'} ";
    $local_sig .= "$decl{$node}{'vec'} " if (defined $decl{$node}{"vec"});
    $local_sig .= "$node ";
    $local_sig .= "$decl{$node}{'arr'}" if (defined $decl{$node}{"arr"});
    $local_sig .= ";\n";
  }
  else {
    my $io_ports_t;
    $io_ports_t .= " $decl{$node}{'dir'} ";
    $io_ports_t .= " $decl{$node}{'type'}";
    $io_ports_t .= " $decl{$node}{'vec'}" if (defined $decl{$node}{"vec"});
    $io_ports_t .= " $node";
    $io_ports_t .= " $decl{$node}{'arr'}" if (defined $decl{$node}{"arr"});
    $io_ports_t .= ",";
    $io_ports_t .= "\n";
    if ($decl{$node}{"auto"} == 1){
      $io_ports_auto .= $io_ports_t;
    } else {
      $io_ports_conf .= $io_ports_t;
    }
  }
}
$io_ports .= "$io_ports_conf";
$io_ports .= " \n// Auto generated ports \n";
$io_ports .= "$io_ports_auto";
$io_ports =~ s/,\n$/\n/;

###############################################################################
# Generate instantiation template
###############################################################################

# Open file to write top level RTL
my $ftop;
my $ftopname = "$top{TOPMODULE}.sv";
open $ftop,'>',$ftopname or die "Cant open file $ftopname. $!";
my $paramInst="";

select $ftop;

foreach my $mods (keys $hash{MODULES}) {
  my $mods_rename = $mods;
  $mods_rename =~ s/#.*//;
  $inst .= "$mods_rename ";
  if (defined $hash{$mods}{PARAM}){
    $inst .= "#( \n";
    foreach my $pname (keys $hash{$mods}{PARAM}) {
      $inst .= "  .$pname($pname),\n"; 
      $topParams{$pname} = $hash{$mods}{PARAM}{$pname};
    }
    $inst =~ s/,\n$/\n/;
    $inst .= ") ";
  }
  $inst .= "$hash{MODULES}{$mods} (\n";
  foreach my $prtname (keys $hash{$mods}{PORT}){
    $inst .= "  .$prtname($hash{$mods}{PORT}{$prtname}{'sig'}),\n";
  }
  $inst =~ s/,\n$/\n);\n\n/;
}

foreach my $param (keys %topParams) {
  $paramInst .= "  parameter $param = $topParams{$param},\n";
}
$paramInst =~ s/,\n$/\n/;

print "module ";
print "#( \n";
print "$paramInst";
print ") ";
print "$top{TOPMODULE} (\n";
print "$io_ports\n";
print ");\n\n";
print "$local_sig\n";
print "$inst";
print "endmodule\n";
select STDOUT;

###############################################################################
# Debug messages
###############################################################################

print Dumper (\%mhash)     if (defined $debug);
print Dumper (\%hash)      if (defined $debug);
print Dumper (\%decl)      if (defined $debug);
print Dumper (\%topParams) if (defined $debug);



