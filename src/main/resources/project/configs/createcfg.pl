#########################
## createcfg.pl
#########################

use ElectricCommander;
use ElectricCommander::PropDB;

use constant {
               SUCCESS => 0,
               ERROR   => 1,
             };

my $opts;

my $PLUGIN_NAME = "EC-Azure";

if (!defined $PLUGIN_NAME) {
    print "PLUGIN_NAME must be defined\n";
    exit ERROR;
}

## get an EC object
my $ec = new ElectricCommander();
$ec->abortOnError(0);

## load option list from procedure parameters
my $x       = $ec->getJobDetails($ENV{COMMANDER_JOBID});
my $nodeset = $x->find("//actualParameter");
foreach my $node ($nodeset->get_nodelist) {
    my $parm = $node->findvalue("actualParameterName");
    my $val  = $node->findvalue("value");
    $opts->{$parm} = "$val";
}

if (!defined $opts->{config_name} || "$opts->{config_name}" eq "") {
    print "config_name parameter must exist and be non-blank\n";
    exit ERROR;
}

# check to see if a config with this name already exists before we do anything else
my $xpath    = $ec->getProperty("/myProject/azure_cfgs/$opts->{config_name}");
my $property = $xpath->findvalue("//response/property/propertyName");

if (defined $property && "$property" ne "") {
    my $errMsg = "A configuration named '$opts->{config_name}' already exists.";
    $ec->setProperty("/myJob/configError", $errMsg);
    print $errMsg;
    exit ERROR;
}

my $cfg = new ElectricCommander::PropDB($ec, "/myProject/azure_cfgs");

# add all the options as properties
foreach my $key (keys %{$opts}) {
    if ("$key" eq "config_name") {
        next;
    }
    $cfg->setCol("$opts->{config_name}", "$key", "$opts->{$key}");
}
exit SUCCESS;