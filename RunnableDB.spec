RunnableDB.pm is a abstract module which should provide base functionatlity
for the RunnableDB for specific analyses

A RunnableDB is a perl module which is to act as a intermediate between
a Runnable and the database. It is meant to provide functions which fetch
the input_id a runnable needs either from the database or other sources
then write that output back to the database

RunnableDB.pm will provide these methods to give some base functionality

A constructor new which expects three arguments, input_id, dbadaptor
and analysis object and will throw an exception if it doesn't receive
one or if either of the objects are of the wrong type

container methods

input_id expects a string which is input_id and stores and returns that 
         string
db       expect an object which is a 
         Bio::EnsEMBL::Pipeline::DBSQL::DBAdaptor and will throw if the 
         object received isn't one.
analysis expects an object which is a Bio::EnsEMBL::Pipeline::Analysis
         and will throw if the object recieved is not one.
query    a container method to hold a query sequence in the form of a 
         Bio::EnsEMBL::Slice adn should throw if not given a Slice
output   a container for an array of results. It should take an array
         reference and push this onto the array. It should throw if
         not passed an array ref and it should also return an array ref
runnable a method to contain the array of runnables to be run 
         expects an single Bio::EnsEMBL::Pipeline::Runnable object and will
         push it onto the array


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
        Runnables

input_is_void this is a flag to indicate to the RunnableDB that the input
        sequence contains too many N's to have it's analysis usually blast
        run on it. This flag is recognised by the pipeline system and the 
        job is labelled as VOID


failing_job_status, this is a container method for an error string. If
    a runnable parses its programs STDERR and wants to report a specific
    error rather than a general FAILED status this is where that string
    ends up. It can be a maximun of 40chars


run RunnableDB implements a generic run method which basically runs through
    the array of runnables and calls run on each one. Then pushes their output
    into RunnableDB::output

write_output RunnableDB will implement a generic write output method
    which gets its adaptor from the child runnabledb and calls store with
    each feature from RunnableDB::output. Each call to store is wrapped in
    an eval if a single store fails the method will throw

Methods the RunnableDB and the pipeline api expect the child modules
to implement

Each child RunnableDB has to implement these methods

fetch_input this is the only obligatory method to be implemented and it
    should do two things. It should know what the input_id it recieves means
    and what input to fetch on that basis. It should also know how to create
    the appropriate runnable and what information to pass to it.


Other methods RunnableDBs need to consider. 

The pipeline exepcts all RunnableDBs to have three methods fetch_input, run
and write_output. RunnableDB.pm implements basic run and write_output methods
which can be used. If the basic write_output method is to be used the child
runnabledb must implement an adaptor method which returns the appropritate 
adaptor to write the results back to the database from the desired database

run
write_output
adaptor
