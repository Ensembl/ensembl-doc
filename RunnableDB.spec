The RunnableDB is a abstract module which provides some base functionality
for the RunnableDBs. The RunnableDBs should provide an interface between
the Database which provides input data and takes output data and the
Runnables which actually run the analyses and interpret their results

The RunnableDB provide several methods to give the child RunnableDBs
some base functionality.

A constructor new which expects three arguments, input_id, dbadaptor
and analysis object and will throw an exception if it doesn't receive
one or if either of the objects are of the wrong type. Any child runnabledb
should only expect to be given these arguments in the constructor. This
is the way all RunnableDBs are instantiated as part of the pipeline so
if a RunnableDB insists on any other constructor arguments it won't beable 
to be run as part of the pipeline.

All the constructor arguments have container methods which check type if 
appropriate

Other container methods are

query    a container method to hold a query sequence in the form of a 
         Bio::EnsEMBL::Slice adn should throw if not given a Slice
output   a container for an array of results. It should take an array
         reference and push this onto the array. It should throw if
         not passed an array ref and it should also return an array ref
runnable a method to contain the array of runnables to be run 
         expects an single Bio::EnsEMBL::Pipeline::Runnable object and will
         push it onto the array
input_is_void this is a boolean toggle meant to indicate that an input
         has too much repeatmasked sequence and shouldn't be run
failing_job_status, container for a string to indicate the status a job
         failed with

Utility methods


fetch_sequence, this method to fetch a slice from the given database.
         has four arguments all are optional. The first should be a 
         DBAdaptor to the database you want the Slice to come from. If not
         passed in the db in RunnableDB::db will be used. The second is a
         name in the format 
         coord_system:version:seq_region_name:start:end:strand. If this
         is not passed the name in RunnableDB::input_id will be used.
         The last is an array ref to an array of logic_names to specify
         if the sequence should be reapeatmasked and what analyses should
         be used for masking. If no masking is desired pass nothing in.
         If you wish all repeats to be masked use an array which looks
         like this [''] if you want no repeats masked pass in an undefined
         value. The last arguement if a toggle if you want the sequence
         soft masked rather than hard masked


parameter_hash, this is a method which takes a string formatted like so
        key => value, key => value and turns it into a hash which can be 
        used in the runnable to be created's constructor. It can optionally
        take a string but if none is passed in it takes the the string from
        RunnableDB::analysis->parameters which is the string in the 
        parameter column of the analysis table. If the string doesn't match
        the required format the whole string is placed in a hash with a key
        of options which is one of the standard arguments expected by 
        Runnables. If there is a comma separated value with no => this
        is given the value of 1



All RunnableDBs must provide these three methods

fetch_input, run and write_output. RunnableDB provides generic run and
write output method. 

run cycles through each runnable on the RunnableDB::runnable array and 
calls run on it then pushes its output onto the RunnableDB:output method

write_output expects the child RunnableDB to implement a get_adaptor
method which returns the appropriate adaptor for output storage. It
also calls Bio::EnsEMBL::Analysis::Tools::FeatureFactory:validate
which expects the output to fit the Bio::EnsEMBL::Feature model.

These two methods can be overidden if they don't provide the functionality
required.

All runnableDBs must implement a fetch input method as inputs can be quite
different between

The fetch input method generally fetches any input either sequence or 
features from the database or information from files and then creates the
runnables using this information and appropriate information from
configuration and the analysis table


