package File::ShouldUpdate;

use strict;
use warnings;
use Time::HiRes qw/ stat /;

use parent 'Exporter';
use vars qw/ @EXPORT_OK /;
@EXPORT_OK = qw/ should_update /;

sub should_update
{
    my ( $filename2, $syntax_sugar, @deps ) = @_;
    if ( $syntax_sugar ne ":" )
    {
        die qq#wrong syntax_sugar - not ":"!#;
    }
    my @stat2 = stat($filename2);
    if ( !@stat2 )
    {
        return 1;
    }
    foreach my $d (@deps)
    {
        my @stat1 = stat($d);
        return 1 if ( $stat1[9] > $stat2[9] );
    }
    return 0;
}

1;

__END__

=head1 NAME

File::ShouldUpdate - should files be rebuilt?

=head1 FUNCTIONS

=head2 my $verdict = should_update($target, ":", @deps);

should $target be updated if it doesn't exist or older than any of the deps.

=cut
