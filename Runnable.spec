Runnable.pm is an abstract module which should provide base functionality
for the Runnables which act as wrappers for other analysis to parse and
process their results. The Aim of the runnable is to provide the ensembl
api an interface to the specific analyses it wishes to run


Runnable.pm will provide some methods to give the wrappers some base 
functionality

A constructor new which can take three arguments all of which are optional
-QUERY a Bio::EnsEMBL::Slice object which contains the sequence the 
    analysis is to be run on
-PROGRAM the program which is to be run
-OPTIONS the commandline options for the program
-WORKDIR the directory in which the analysis should run

container methods

query a container for Bio::EnsEMBL::Slice object which throws if the object
    passed in is not a Slice
program a container for the program name and/or path
options a container for the command line options
output a container for the array of output. will expect to be passed a 
    feature and will return an array ref
files_to_delete an array of filenames to be deleted. Takes a string 
returns an arrayref
files_to_protect an array of filenames which must not be deleted takes a 
string and returns an arrayref
workdir holds the path to the working directory. This can be set in the
    constructor. By default is takes the $PIPELINE_WORK_DIR variable
    defined in General.pm and default to /tmp if nothing is defined
queryfile the name of the file containing the query_sequence
resultsfile the name of the file containing the results sequence

Utility methods

locate_executable this uses configuration settings and core code from
    Bio::EnsEMBL::Analysis::Programs to locate where the executable is
    and ensure if can be executed for the Runnable
get_temp_filename will generate a temporary filename on the basis of the
    stub and extension which is passed in. The tempory filename includes
    process_id and a random number
write_seqfile a method which uses Bio::SeqIO to write a fasta file
    the method optionally takes a sequence argument but if not specified
    it will take the Bio::EnsEMBL::Slice from Runnable::query
find_file, this will find the location of a file by first checking the 
    current working then looking in directories specified in General.pm
delete_files this delete the files listed by the Runnable:files method
    but not on the protect list
checkdir check the workdir has enough space for the run in it
diskspace actually calculates the amount of diskspace availible
clean_output a method which empties the output array, some runnables use
    the output array and a place holder and this method would allow it to 
    be emptied and replaced if required
create_filename, method which is passed a stem and a stub and produces
a unique filename

about 40% of runnables use a run method which basically looks like this
and there are more runnables who arguably could use a run method which
looked like this. It should accomodate any analysis which runs a analysis
which requires a single sequence to run with

sub run {
    my ($self, $dir) = @_;

    $self->throw("Query seq required for Blast\n") unless($self->query);
   
    $self->workdir('/tmp') unless ($self->workdir($dir));
    $self->checkdir();
   
    #write sequence to file
    $self->write_seqfile(); 
    $self->run_analysis();
    
    #parse output and create features
    $self->parse_results;
   
    $self->delete_files();
   
    return 1;
}


and most runnables need a run_analysis method like this

sub run_analysis{
    my ($self, $program) = @_;

    if(!$program){
     $program = $self->program;
    }
    throw("Can't run ".$self." with out a program name or if ".$program.
    " is not executable") if(!$program || ! -x $program);
    my $commandline = $program." ".$self->queryfile." ".$self->options." > ".
    $self->resultsfile;
    print STDOUT "COMMAND LINE ".$commandline."\n";
    eval{
     system($commandline);
    };
    if($@){
      throw("PROBLEM RUNNING ".$commandline." $@ ");
    }
}


as such it may be a good idea to absract this method down to this level 
and force those modules which utilize it to implement their own 
parse_results method but still allowing those runnables
who deal with a more complex analysis to override the method
