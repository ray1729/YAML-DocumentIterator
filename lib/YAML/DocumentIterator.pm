package YAML::DocumentIterator;

use strict;
use warnings FATAL => 'all';

use YAML::Syck;
use UNIVERSAL 'isa';
use Carp 'croak';
use IO::Handle;
use IO::File;
use Iterator;

sub new {
    my ( $class, $in ) = @_;

    my $ifh;
    if ( not defined $in ) {
        $ifh = IO::Handle->new_from_fd( fileno(STDIN) );
    }
    elsif ( UNIVERSAL::isa($in, 'IO::Handle' ) ) {
        $ifh = $in;
    }
    else {
        $ifh = IO::File->new( $in, O_RDONLY )
          or croak "open $in: $!";
    }

    my $line = $ifh->getline();

    return Iterator->new(
        sub {
            while ( defined $line and $line ne "---\n" ) {
                $line = $ifh->getline;
            }
            Iterator::is_done() unless defined $line;
            my $record = $line;
            while ( defined( $line = $ifh->getline ) and $line ne "---\n" ) {
                if ( $line eq "...\n" ) {
                    $line = $ifh->getline;
                    last;
                }
                $record .= $line;
            }
            return YAML::Syck::Load( $record );
        }
    );
}

1;

__END__

=pod

=head1 NAME

YAML::DocumentIterator

=head1 SYNOPSIS

  my $data = YAML::DocumentIterator->new( 'data.yaml' );
  while ( $data->isnt_exhausted ) {
      my $datum = $data->value;
      # ...do something with $datum
  }

=head1 DESCRIPTION

This module provides a small wrapper around C<YAML::Syck::Load> to
read and parse a YAML file one record at a time. This is sometimes
preferable to the behaviour of C<YAML::LoadFile>,
C<YAML::Syck::LoadFile>, and C<YAML::XS::LoadFile> which read the
entire file into memory before parsing.

=head1 METHODS

=over 4

=item new(I<$file>)

Constructor. I<$file> can be either an open L<IO::Handle> or the name
of a file to be opened for reading. Returns an L<Iterator> object.

=back

=head1 SEE ALSO

L<YAML::Syck>, L<Iterator>.

=head1 AUTHOR

Ray Miller E<lt>ray@1729.org.ukE<gt>.

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
