Runnable.pm is an abstract module which should provide base functionality
for the Runnables which act as wrappers for other analysis to parse and
process their results. The Aim of the runnable is to provide the ensembl
api an interface to the specific analyses it wishes to run


All runnables should provide to methods run and output. There are
generic versions of these methods in the base clase but this can be overridden
by child Runnables if their structure isn't appropriate


Runnable.pm will provide some methods to give the wrappers some base 
functionality

A constructor new which can take 8 arguments only one of which is obligatory
-ANALYSIS a Bio::EnsEMBL::Analysis object and this is complusory
-QUERY a Bio::EnsEMBL::Slice object which contains the sequence the 
    analysis is to be run on
-PROGRAM the program which is to be run
-OPTIONS the commandline options for the program
-WORKDIR the directory in which the analysis should run
-BINDIR the directory some binarys live in
-LIBDIR the directory where libary files live
-DATADIR the directory where data files live

note all the directories soecfied are optional arguments whoes location
can be take from Bio::EnsEMBL::Analysis::Config::General if note specified 
here


There are container methods for the all the constructor arguments which do
type checking where appropriate. The program method also calls
locate_executable to try and make sure it can find the program

Other container methods

output a container for the array of output. will expect to be passed a 
    an arrayref and will return an array ref

files_to_delete, this takes single file names and add them to a hash keyed
    on the filename. It returns the hashref

files_to_protect this takes single file names and add them to a hash keyed
    on the filename. It returns the hashref

queryfile the name of the file containing the query_sequence, it the 
method is called but no name is defined it will generate its name and
if not defined the results filename

resultsfile the name of the file containing the results sequence

featurefactory container for a Bio::EnsEMBL::Analysis::FeatureFactory
object

Utility methods

locate_executable this uses configuration settings and core code from
    Bio::EnsEMBL::Analysis::Programs to locate where the executable is
    and ensure if can be executed for the Runnable

create_filename, this create a random filename based on the stem, 
extension and directory passed in including a random number and the process
id

write_seq_file a method which uses Bio::SeqIO to write a specified fasta 
    file name the method optionally takes a sequence argument and filename
    but if not specified it will take the Bio::EnsEMBL::Slice from 
    Runnable::query and the filename from Runnable:queryfile

find_file, this will find the location of a file by first checking the 
    current working then looking in directories specified in General.pm

delete_files this delete the files in the files_to_delete hash but not 
    those in the files to protect hash

checkdir check the workdir has enough space for the run in it

diskspace actually calculates the amount of diskspace availible

clean_output a method which empties the output array, some runnables use
    the output array and a place holder and this method would allow it to 
    be emptied and replaced if required



All Runnables need to provide a run method. This method to coordinate
the running of the analysis and the parsing of the results.

Runnable.pm provides a generic run method which works on these assumptions
Your runnable needs a query sequence and your Runnable has a run_analysis 
and a parse_results method. Runnable.pm does provide a generic run_analysis
method which assumes the commandline structure 

program options queryfile > resultsfile
