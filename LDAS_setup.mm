.\" $Id$
.\"
.\" Andreas Kähäri
.\" andreas.kahari@ebi.ac.uk
.\"
.\"  Format with GNU troff like this:
.\"     groff -t -mm LDAS_setup.mm >LDAS_setup.ps
.\"
.\"  To get it from Postscript into PDF:
.\"     ps2pdf LDAS_setup.ps LDAS_setup.pdf
.\"
.\"  Plain text ("cat -s" removes multiple blank lines):
.\"     groff -Tlatin1 -t -mm LDAS_setup.mm | /bin/cat -s >LDAS_setup.txt
.\"
.
.\" Small caps for these two names
.ds UNIX \s[-2]UNIX\s[+2]
.ds POSIX \s[-2]POSIX\s[+2]
.
.\" Sizes for headings level 1, 2, and 3
.ds HP +4 +2 +1
.\" Use roman font style for all headings
.ds HF  R  R  R
.
.\" Nothing in page header, page number in page foot (unless
.\" we're in plain text/nroff mode).
.PH "''''"
.ie t
.PF "''-%-''"
.el
.PF "''''"
.
.DS C
.S +4
Setting up a Lightweight DAS server
.S -2
\&... and connecting it to Ensembl
.S D
.DE
.DS
.VL 9
.LI "Date:"
\*[DT]
.LI "Author:"
Andreas K\(:ah\(:ari,  European Bioinformatics Institute (EBI)
.br
\fCandreas.kahari@ebi.ac.uk\fP
.LE
.SP
.S -2
$Revision$
.S D
.DE
.
.SP
.H 1 "Introduction"
.P
This document is a log of how I installed the LDAS server
for personal use.  One may read it as a short step-by-step
guide on how to set up a Lightweight DAS (LDAS) server on a
\*[UNIX] workstation and have its data attached as tracks in the
\(lqContigView\(rq display of the Ensembl genome browser (or for
whatever purpose one might want to set up a DAS service).
.P
The LDAS server was written by Lincoln Stein at the Cold
Spring Harbor Laboratory, and is based on Perl and the BioPerl
framework.  This is by no means the only easy to use DAS server
available, and the site at
.DS I
\fChttp://www.biodas.org/\fP
.DE
also lists the Dazzle server which is based on Java and the
BioJava toolkit.  If you want to set up a Dazzle server to use
with Ensembl, wander off to the Ensembl documentation page at
.DS I
\fChttp://www.ensembl.org/Docs/\fP
.DE
and look for the \(lqDAS Server Install document\(rq, written by
Tony Cox at the Sanger institute.  That text might also be used
as a complement this document.
.P
After reading and carrying out the instructions in this text,
you should have a LDAS server running on your \*[UNIX] machine,
and an extremly simple sample DAS feature track displayed in the
Ensembl browser.
.P
The LDAS home web site is located at
.DS I
\fChttp://www.biodas.org/servers/\fP
.DE
and contains, apart from the server itself, additional
(authoritive) documentation.  At one point or another, you will
need to read that documentation as well.
.SP
.H 2 "What we will be doing"
.P
I will assume that you have machine running one or another
\*[UNIX]-like operating system.  Root access on the machine
is not required, but is preferred as you might run into some
security issues otherwise (I will point these out).  The system
that I used was a standard issue EBI office Red Hat Linux
system, release 7.1.  I'm most comfortable using command shells
compatible with the \*[POSIX] shell (sh, pdksh, ksh93, bash,
ash, zsh, etc.)  Users of tcsh and csh will need to translate a
few lines, but the rest of you should be ok.
.P
We will quickly go through the installation of the following
things:
.AL
.LI
The Apache web server, version 1.3.17 or later.  I'm using
version 1.3.27.
.LI
MySQL, version 3.23 or later.  I'm using version 3.23.55.
.LI
Perl, version 5.6.1 or later.  At the time of writing, the
latest stable version of Perl is 5.8.0.  You will also need to
install the following Perl bundles from CPAN:
.AL
.LI
\fCBundle::DBI\fP, version 1.20 or higher.  I'm using version
1.32.
.LI
\fCBundle::DBD::mysql\fP, version 1.22 or higher.  I'm using
version 1.2219.
.LI
\fCBundle::BioPerl\fP, which is at version 1.2 at the time of
writing. \&...or at least the \fCBio::DB::GFF\fP module version
0.38 or higher.
.LE
.P
Optionally, you might also want to install the \fCmod_perl\fP
distribution, version 1.24 or higher, and the \fCApache::DBI\fP
module, version 0.88 or higher.
.LI
The Lightweight DAS server itself.  I'm using version 1.09.
.LE
.P
Many of these components might already be installed on your
system, or might be available as packages specifically made for
your operating system.  Take a look on your distribution CDs, or
make your sysadmin have a look.
.P
I'm assuming that you do not have root access, so you will not
be able to write into e.g. \fC/usr/local\fP on your \*[UNIX]
machine.  You will need access to a directory that you have
permission to write to.  You will use this firectory as an
\(lqalternative root directory\(rq.  Replace any mentioning
of \fC$ALTROOT\fP with your chosen directory (there's nothing
stopping you from using \fC/\fP as the \fC$ALTROOT\fP if you
have root access).  Also, make sure \fC$ALTROOT/bin\fP and
\fC$ALTROOT/sbin\fP are first in you \fC$PATH\fP variable.  You
will eventually also need to cram \fC$ALTROOT/mysql/bin\fP in
there, so you might as well add it now.
.DS I
.ft C
$ \f(CBPATH=$ALTROOT/bin:$ALTROOT/sbin:$ALTROOT/mysql/bin:$PATH\fP
$ \f(CBexport PATH\fP
.ft R
.DE
.SP
.H 2 "About GNU Stow"
.P
I have been using the GNU Stow program for handling software
packages for a couple of years, and I also used it when getting
LDAS going.  The GNU Stow program, which is a Perl script
that requires Perl version 5.005 or later, makes it a lot
easier to manage software packages and effectively stops
\fC/usr/local\fP (or \fC/opt\fP or whatever you preferred third
party installation root directory might be) from getting messy.
Get it from
.DS I
\fChttp://www.gnu.org/directory/stow.html\fP
.DE
or from one of the GNU FTP mirrors.  If you're
using GNU Stow, install all programs into
\fC$ALTROOT/stow/\fP\f(CIpackagename-version\fP instead of
straight into \fC$ALTROOT\fP, then stow the package as described
in the GNU Stow documentation.  Executable binaries and scripts
will be symbolically linked from \fC$ALTROOT/bin\fP, so the
inital \fC$PATH\fP won't need to be changed from what I said
above.
.
.SP
.H 1 "Installation"
.H 2 "Install a recent version of Perl"
.P
This can be done in several ways depending on your \*[UNIX].
The by far easiest way if you already have a version of Perl
installed is to go through the CPAN shell:
.DS I
.ft C
$ \f(CBperl -MCPAN -e shell\fP

cpan shell -- CPAN exploration and modules installation (v1.65)
ReadLine support enabled

cpan> \f(CBinstall J/JH/JHI/perl-5.8.0.tar.gz\fP

Beginning of configuration questions for perl5.

Checking echo to see how to suppress newlines...
\&...using -n.
The star should be here-->*

[...]
.ft R
.DE
.P
Installing Perl directly from the unpacked source tarball is
quite easy as well (read the INSTALL document in tarball):
.DS I
.ft C
$ \f(CBsh Configure\fP

Beginning of configuration questions for perl5.

Checking echo to see how to suppress newlines...
\&...using -n.
The star should be here-->*

[...]

$ \f(CBmake\fP
$ \f(CBmake test\fP
$ \f(CBmake install\fP
.ft R
.DE
.P
At the time of writing, the source tarball for Perl 5.8.0 can be
fetched from
.DS I
\fChttp://cpan.org/src/README.html\fP
.DE
.P
The important question during the configuration is
\(lqInstallation prefix to use?\(rq.  Answer with your
choise of \fC$ALTROOT\fP.  Also, you probably want to answer
\fCn\fP to the question \(lqDo you want to install perl as
/usr/bin/perl\(rq.
.P
I had to bypass the testing stage of the installation since one
of the tests kept failing.  Just add \fCforce\fP in front of
\fCinstall\fP if you're using the CPAN shell, or just ignore the
\fCmake test\fP step if you have problems with this.  It seems
to be working fine anyways.
.SP
.H 2 "Install the Apache web server"
.P
Depending on whether or not you decide to install the
\fCmod_perl\fP distribution, the installation of the Apache
web server will differ.  I will describe how to install the
server with \fCmod_perl\fP disabled.  People wanting to install
\fCmod_perl\fP should look in the \fCmod_perl\fP documentation
for installation instructions.
.P
The Apache web server source tarball may be found at
.DS I
\fChttp://httpd.apache.org/download.cgi\fP
.DE
and once it has been unpacked, the configuration, building and
installation of the package is, at least for version 1.3.27, a
simple matter of saying
.DS I
.ft C
$ \f(CB./configure --prefix=$ALTROOT --with-layout=GNU\fP
$ \f(CBmake\fP
$ \f(CBmake install\fP
.ft R
.DE
.P
This should install the executables in \fC$ALTROOT/bin\fP,
the document root of the server is set to
\fC$ALTROOT/share/htdocs\fP, the CGI scripts should be
located in \fC$ALTROOT/share/cgi-bin\fP, the server error
and access logs goes into \fC$ALTROOT/var/log\fP, and the
configutration files goes into \fC$ALTROOT/etc\fP. Edit
\fC$ALTROOT/etc/httpd.conf\fP to suit your setup.  The default
port that the server will listen to will be set to 8080.
.P
Users of GNU Stow might want to change the document root and the
CGI directory (and might then also want to allow symbolic links
to be followed in the CGI directory).  For a personal server
like this, you should be extra careful to only allow access
from the hosts that really need to access the server, either by
properly configuring a firewall, or by configuring the Apache
server itself.
.P
I had to remove a number of plus signs from GNU layout
section of the file \fCconfig.layout\fP before running the
\fCconfigure\fP script.  I also changed the prefix setting
in the same section to match the argument given to the
\fCconfigure\fP script on the command line.
.P
.ne 3
Pointing a web browser to
.DS I
\fPhttp://localhost:8080/\fP
.DE
should show the standard Apache boiler plate page (a
page entitled \(lqSeeing this instead of the website you
expected?\(rq).  This means that the web server is functional.
.SP
.H 2 "Install MySQL"
.P
Because of a bug in version 2.96 of the GNU C compiler on my
system I couldn't install MySQL from source, so I got the binary
distribution tarball instead. Fetch MySQL from the download page
at
.DS I
\fChttp://www.mysql.com/downloads/\fP
.DE
.P
Install it as e.g. \fC$ALTROOT/mysql\fP.  For instructions,
see e.g. the \fCINSTALL-BINARY\fP document in the tarball
if you're installing a binary distribution of MySQL.
.P
When done, add \fC$ALTROOT/mysql/bin\fP to your \fC$PATH\fP
environment variable (if you haven't done so already) and start
a MySQL deamon:
.DS I
.ft C
$ \f(CBPATH=$ALTROOT/mysql/bin:$PATH; export PATH\fP
$ \f(CBcd $ALTROOT/mysql\fP
$ \f(CB./bin/safe_mysqld &\fP
.ft R
.DE
.P
You will also have to change the MySQL root user password:
.DS
.ft C
$ \f(CB./bin/mysqladmin -u root password '\fP\f[CBI]new-password\fP\f(CB'\fP
$ \f(CB./bin/mysqladmin -u root -h \fP\f[CBI]uhuru.ebi.ac.uk\fP\f(CB password '\fP\f[CBI]new-password\fP\f(CB'\fP
.ft R
.DE
Replace \(lqnew-password\(rq with the chosen password, and
replace \fCuhuru.ebi.ac.uk\fP with the name of your machine.
.SP
.H 2 "Install the Perl modules"
.P
We do this after installing and starting MySQL since one of the
test steps includes connecting to a test database.
.P
It's easy to use the CPAN shell to install the needed modules
(you might need to reconfigure your old CPAN configuration by
deleting \fC\(ti/.cpan/CPAN/MyConfig.pm\fP):
.DS I
.ft C
$ \f(CBperl -MCPAN -e shell\fP
[...]
cpan> \f(CBinstall Bundle::DBI\fP
cpan> \f(CBinstall Bundle::DBD::mysql\fP
cpan> \f(CBinstall Bundle::BioPerl\fP
cpan> \f(CBexit\fP
.ft R
.DE
.P
I had to force install some of the above bundles since one or
two test failed.  Just add \fCforce\fP before the \fCinstall\fP
command.  Also, the \fCSOAP::Lite\fP module (needed by
\fCBundle::BioPerl\fP), version 0.55, seems to suffer from
file permission problems and needs to get manual help to be
installed:
.DS I
.ft C
[...]
inflating: SOAP-Lite-0.55/t/TEST.pl
Couldn't rename SOAP-Lite-0.55 to [...]/SOAP-Lite-0.55:
Permission denied at [...]/lib/perl5/5.8.0/CPAN.pm line 3903

cpan> \f(CBexit\fP
$ \f(CBcd \(ti/.cpan/build/tmp\fP
$ \f(CBchmod -R u+w SOAP-Lite-0.55\fP
$ \f(CBcd SOAP-Lite-0.55\fP
$ \f(CBperl Makefile.PL\fP
$ \f(CBmake\fP
$ \f(CBmake install\fP
$ \f(CBcd\fP
$ \f(CBperl -MCPAN -e shell\fP
cpan> \f(CBinstall Bundle::BioPerl\fP
[...]
.ft R
.DE
Of course, you may choose to only install the \fCBio::DB::GFF\fP
module instead of installing the whole BioPerl bundle (wich also
requires the Expat XML parser and the GD graphics library).
.P
The only additional step that needs to be taken is to ensure
that the scripts in the \fCscripts/Bio-DB-GFF\fP directory of
the BioPerl distribution is available in your \fC$PATH\fP, maybe
by copying them to \fC$ALTROOT/bin\fP:
.DS I
.ft C
$ \f(CBcp \(ti/.cpan/build/bioperl-1.2/scripts/Bio-DB-GFF/*.pl $ALTROOT/bin\fP
.ft R
.DE
.SP
.H 2 "Install the Lightweight DAS server"
.P
Get the LDAS server from
.DS I
\fChttp://www.biodas.org/download/ldas/\fP
.DE
and unpack the tarball.  Run Perl on the supplied \fCMakefile.PL\fP script and enter the correct paths to the Apache configuration directory and the CGI directory.  Then make and install:
.DS I
.ft C
$ \f(CBperl Makefile.PL\fP
[...]
$ \f(CBmake\fP
$ \f(CBmake install\fP
.ft R
.DE
.P
Edit the LDAS CGI script and specify the location of the
\fCdas.conf\fP dicretory.  In my case, I had to change the line
.DS I
\fC$CONF_DIR = '/usr/local/apache/conf/das.conf';\fP
.DE
of \fC$ALTROOT/share/cgi-bin/das\fP into
.DS I
\fC$CONF_DIR = '/scratch/altroot/etc/das.conf';\fP
.DE
(\fC/scratch/altroot\fP happens to be the value of
\fC$ALTROOT\fP that I used).
.P
Pointing a browser to
.DS I
\fChttp://localhost:8080/cgi-bin/das\fP
.DE
should now give you a page just containing the words \(lqinvalid
request\(rq (this is an error message from LDAS, but at the
moment it tells us that LDAS alive and well).
.
.SP
.H 1 "Adding sample data to the LDAS server"
.P
Just to show how to add a simple DAS track to the Ensembl genome
browser, let's use Ensembl to extract some data.  Then we'll add
that data to our personal MySQL database and make it available
in Ensembl.
.P
For more in-depth documentation about how to properly set up the
database, please refer to the \(lqSETTING UP THE DATABASE\(rq
section of the LDAS documentation at
.DS I
\fChttp://www.biodas.org/servers/LDAS.html\fP
.DE
.SP
.H 2 "Get the data"
.P
DAS servers are of two kinds, reference servers and annotation
servers.  We're not setting up a reference DAS server so we
won't need any assembly information.  We still need to fetch
reference and annotation data though.
.P
Using the Ensembl MartView datamining tool at
.DS I
\fChttp://www.ensembl.org/Homo_sapiens/martview\fP
.DE
do the following selections:
.TS
box center;
l|l
__
l|l
.
Page	Select
START	Homo sapiens
	Ensembl Genes
REGION	Chromosome 7
FILTER	Known Genes only
	Transmembrane Domains only
OUTPUT	Output type, Structure
	Output format, GTF
.TE
.P
Then just press \(lqexport\(rq and save the output as e.g.
\fChuman_tm_7.gff\fP on you \*[UNIX] account.  This file will be
turned into our annotation file.
.P
The GFF data in \fChuman_tm_7.gff\fP needs to be reorganised
for the LDAS loading scripts to understand it.  The following
command sequence does that and saves the result to a file called
\fChuman_tm_7.das\fP:
.DS I
.ft C
$ \f(CBawk 'BEGIN { OFS="\\t"; print "[annotations]"; }
    {
        print "Gene", $10, $3, $2, $1, $4, $5, $7, $6, $8;
    }' human_tm_7.gff | tr -d ';' >human_tm_7.das\fP
.ft R
.DE
.P
The reference file be a tab delimited text file, call it
something like \fChuman_tm_7_ref.das\fP, looking like this:
.DS I
.ft C
[references]
#id     class           length
7       Chromosome      157432793
.ft R
.DE
.P
The length of chromosome 7 my be found at
.DS I
\fChttp://www.ensembl.org/Homo_sapiens/mapview?chr=7\fP
.DE
or by executing the following SQL query (will get the lengths of all chromosomes):
.DS I
.ft C
$ \f(CBmysql --host kaka.sanger.ac.uk --user anonymous -e \\
    'SELECT chromosome_id,name,length
     FROM chromosome
     WHERE chromosome_id < 25
     ORDER BY chromosome_id' homo_sapiens_core_10_30\fP
.ft R
.DE
.P
The file name extension on the reference and annotation files
must be \fC*.das\fP, or the load scripts will be confused.  The
two files may also be concatenated to form a single load file.
If you do this, make sure that the \fC[references]\fP section
comes before the \fC[annotations]\fP section.
.SP
.H 2 "Prepare the database"
.P
We need to set up a MySQL database that will hold the data.
Make sure there is a MySQL deamon alive on your machine and
then...
.DS I
.ft C
$ \f(CBmysql --user root -p\fP
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \\g.
Your MySQL connection id is 7 to server version: 3.23.55

Type 'help;' or '\\h' for help. Type '\\c' to clear the buffer.

mysql> \f(CBCREATE DATABASE human;\fP
Query OK, 1 row affected (0.00 sec)

mysql> \f(CBGRANT ALL PRIVILEGES ON human.* TO ak@localhost;\fP
Query OK, 0 rows affected (0.00 sec)

mysql> \f(CBGRANT FILE ON *.* TO ak@localhost;\fP
Query OK, 0 rows affected (0.00 sec)

mysql> \f(CBGRANT SELECT ON human.* to ak@localhost;\fP
Query OK, 0 rows affected (0.00 sec)

mysql> \f(CBQUIT;\fP
Bye
.ft R
.DE
.P
The first \fCGRANT\fP command in this example show all
privileges (select, update, create, delete) being granted to
users who log in as \fCak\fP (me) from the local machine.  You
will want to change the user name to your own login name.
.P
The second \fCGRANT\fP command grants file permissions to this
user so that he can use the bulk loader. Because of the way
MySQL's bulk loading works, the file permission must be granted
to all databases (\fC*.*\fP) and not just to a single one.
.P
The third \fCGRANT\fP command grants \fCSELECT\fP permissions
to the user running the Apache web server.  This enables the
web server script to read the \fChuman\fP database, but not to
update or otherwise change it.  Note that we in this particular
example have \fIa potential security issue here\fP since the
user allowed to make changes to the database happens to be the
same as the user running the web server...  On a production
or publicly available system, you should really be using two
separate users for running the web and MySQL servers.
.P
Let me repeat that: \fIOn a production or publicly available
system, you should really be using two separate users for
running the web and MySQL servers.\fP
.SP
.H 2 "Load the data into the database"
.P
The LDAS server comes with a Perl script that makes the loading
of the data into the database very easy.  Just specify what
files you want to have loaded and into what database you want to
load them:
.DS I
.ft C
$ \f(CBldas_load.pl --create --database human \\
    human_tm_7_ref.das human_tm_7.das\fP
human_tm_7_ref.das: loading...
[...]
human_tm_7.das: 4352 records loaded
.ft R
.DE
.SP
.H 2 "Configure the server with the new data"
.P
The LDAS serve needs to be able to find a configuration file in
the \fC$ALTROOT/etc/das.conf\fP directory that tells it that
there now is data in the database.  This configuration file
could be called \fChuman.conf\fP and look like this:
.DS I
.ft C
[DATA SOURCE]
description = Human Chomosome 7 (test)
adaptor     = dbi::mysqlopt
database    = dbi:mysql:database=human;host=localhost
mapmaster   = http://your.host.name.here:8080/cgi-bin/das/human

[CATEGORIES]
default     = structural

[LINKS]

[COMPONENTS]

[FILTER]
.ft R
.DE
.P
This is a very minimalistic configuration file for test purposes
and you should replace \fCyour.host.name.here:8080\fP with
whatever the name of your host may be, followed by the correct
port to access the Apache web server.  Please refer to the LDAS
documentation for a proper description of the format of the
configuration file.
.P
You should now be able to point your browser at
.DS I
\fChttp://localhost:8080/cgi-bin/das/dsn\fP
.DE
which will give you the data sources of the DAS server.  In the
reply, you should be able to find the lines
.DS I
.ft C
<DSN>
  <SOURCE id="human">human</SOURCE>
  <MAPMASTER>http://your.host.name.here:8080/cgi-bin/das/human</MAPMASTER>
  <DESCRIPTION>Human Chomosome 7 (test)</DESCRIPTION>
</DSN>
.ft R
.DE
.SP
.H 2 "Adding the source to Ensembl"
.P
Finally, fire up the browser again and point it to the Ensembl
web site showing the human chromosome 7 at
.DS I
\fChttp://www.ensembl.org/Homo_sapiens/mapview?chr=7\fP
.DE
.P
Click anywhere on the map of the chromosome on the left and
locate the \(lqDAS Sources\(rq menu on the page that appears.
Choose \(lqManage sources...\(rq from that menu and click the
\(lqAttach DAS\(rq button.  Enter
.DS I
\fCyour.host.name.here:8080/cgi-bin/\fP
.DE
and click the \(lqShow sources\(rq button.  You should now be
able to select the new source and click \(lqAttach DAS\(rq
to attach it to the Ensembl browser.  You will need to press
\(lqRefresh\(rq in the genome browser window to refresh the
view.
.P
If you can't see any features on your track, that's probably
because you're not viewing an area on which there are any
features.  Refer to the \fC[annotations]\fP section of your load
files to see where you might find a feature.
.P
You're now ready to add your own data to LDAS. Please
refer to the LDAS configuration documentation at
\fChttp://www.biodas.org/servers/LDAS.html\fP.
