package Data::Printer::Filter::DBIx::Class;

use strict;
use warnings;

use Data::Printer::Filter;
use Term::ANSIColor;

# DBIx::Class filters
filter '-class' => sub {
    my ( $obj, $properties ) = @_;

    # TODO: if it's a Result, show columns and relationships (anything that
    #       doesn't involve touching the database
    if ( $obj->isa( 'DBIx::Class::Row' ) ) {
        my %row = $obj->get_columns;
        return p( %row );
    }
    elsif ( $obj->isa( 'DBIx::Class::ResultSet' ) ) {
        my @rows;
        while ( my $row = $obj->next ) {
            push @rows, { $row->get_columns };
        }
        return np( @rows );
    }
    else {
        return;
    }
};

1;
__END__
