use strict;
use warnings;

package Data::Printer::Filter::DBIx::Class;

use Data::Printer::Filter;
use Term::ANSIColor;

# DBIx::Class filters
filter '-class' => sub {
    my ( $obj, $properties ) = @_;

    if ( $obj->isa( 'DBIx::Class::Row' ) ) {
        my %row = $obj->get_columns;
        return _add_prefix( $obj, $properties, \%row );
    }

    if ( $obj->isa( 'DBIx::Class::ResultSet' ) ) {
        my @rows;
        while ( my $row = $obj->next ) {
            push @rows, { $row->get_columns };
        }
        return _add_prefix( $obj, $properties, @rows );
    }

    return;
};

sub _add_prefix {
    my $obj        = shift;
    my $properties = shift;
    my @rows       = @_;

    my $str = colored( ref( $obj ), $properties->{color}{class} );
    $str .= ' (' . $obj->result_class . ')' if $obj->can( 'result_class' );

    if ( $obj->can( 'as_query' ) ) {
        my $query_data = $obj->as_query;
        my @query_data = @$$query_data;
        indent;
        my $sql = shift @query_data;
        $str
            .= ' {'
            . newline
            . colored( $sql, 'bright_yellow' )
            . newline
            . join( newline,
            map { $_->[1] . ' (' . $_->[0]{sqlt_datatype} . ')' }
                @query_data );
        outdent;
        $str .= newline . '}';

    }

    # Remove require once Data::Printer > 0.36 is released
    require Data::Printer;

    return $str . q{ } . Data::Printer::np( @rows );
}
1;

__END__

# ABSTRACT: Apply special Data::Printer filters to DBIx::Class objects

=pod

=head1 SYNOPSIS

In your program:

    use Data::Printer filters => { -external => ['DBIx::Class'] };

or, in your C<.dataprinter> file:

    { filters => { -external => ['DBIx::Class'] } };

=head1 DESCRIPTION

Huge chunks of this have been lifted directly from L<Data::Printer::Filter::DB>
This filter differs in that it also adds the values from C<get_columns()> to
the output.  For a L<DBIx::Class::Row> object, the column values are return in
the data.  For a L<DBIx::Class::ResultSet>, all of the rows in the ResultSet
are returned, with the contents of C<get_columns()> included.  If you're
dealing with huge ResultSets, this may not be what you want.  Caveat emptor.

=cut
