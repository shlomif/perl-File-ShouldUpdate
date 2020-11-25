package File::ShouldUpdate;

use strict;
use warnings;
use Time::HiRes qw/ stat /;

use parent 'Exporter';
use vars qw/ @EXPORT_OK /;
@EXPORT_OK = qw/ should_update should_update_multi /;

sub should_update_multi
{
    my ( $new_files, $syntax_sugar, $deps ) = @_;
    if ( $syntax_sugar ne ":" )
    {
        die qq#wrong syntax_sugar - not ":"!#;
    }
    my $min_dep;
    foreach my $filename2 (@$new_files)
    {
        my @stat2 = stat($filename2);
        if ( !@stat2 )
        {
            return 1;
        }
        my $new = $stat2[9];
        if ( ( !defined $min_dep ) or ( $min_dep > $new ) )
        {
            $min_dep = $new;
        }
    }
    foreach my $d (@$deps)
    {
        my @stat1 = stat($d);
        return 1 if ( $stat1[9] > $min_dep );
    }
    return 0;
}

sub should_update
{
    my ( $filename2, $syntax_sugar, @deps ) = @_;
    if ( $syntax_sugar ne ":" )
    {
        die qq#wrong syntax_sugar - not ":"!#;
    }
    return should_update_multi( [$filename2], $syntax_sugar, \@deps );
}

1;

__END__

=head1 NAME

File::ShouldUpdate - should files be rebuilt?

=head1 SYNOPSIS

    use File::ShouldUpdate qw/ should_update should_update_multi /;

    if (should_update("output.html", ":", "in.tt2", "data.sqlite"))
    {
        system("./my-gen-html");
    }

    if (should_update_multi(["output.html", "about.html", "contact.html"], ":", ["in.tt2", "data.sqlite"]))
    {
        system("./my-gen-html-multi");
    }

=head1 DESCRIPTION

This module provides should_update() which can be used to determine if files
should be updated based on the mtime timestamps of their dependencies. It avoids
confusing between target and dependencies by using syntactic sugar of the
familiar makefile rules ( L<https://en.wikipedia.org/wiki/Make_(software)> ).

=head1 FUNCTIONS

=head2 my $verdict = should_update($target, ":", @deps);

Should $target be updated if it doesn't exist or older than any of the deps.

=head2 my $verdict = should_update_multi([@targets], ":", [@deps]);

Should @targets be updated if some of them do not exist B<or> any of them are older than any of the deps.

Note that you must pass array references.

[Added in version 0.2.0.]

=cut
