use strict;
use warnings;

package DBIx::Class::ResultSet;

use feature qw( state );

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub as_query { \['SELECT * FROM my_table'] }

sub next {
    state $counter = 0;
    return if $counter == 1;
    ++$counter;
    return DBIx::Class::Row->new;
}

sub result_class {'MyResultClass'}

1;

package DBIx::Class::ResultSet::HRI;

our @ISA = ( 'DBIx::Class::ResultSet' );
use feature qw( state );

sub next {
    state $counter = 0;
    return if $counter == 1;
    ++$counter;
    return { foo => 'bar', baz => 'qux', };
}

1;

package DBIx::Class::Row;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub get_columns {
    return ( foo => 'bar', baz => 'qux', );
}

1;

package main;

use strict;
use warnings;

use Test::More;

use Data::Printer filters => { -external => [ 'DB', 'DBIx::Class' ] };

{
    my $row      = np( DBIx::Class::Row->new );
    my $filtered = np( $row );
    diag $row;
    like( $row, qr{DBIx::Class::Row}, 'row data has package name' );
    like( $row, qr{qux}, 'row data has column value' );
}

{
    my $row      = np( DBIx::Class::ResultSet->new );
    my $filtered = np( $row );
    diag $row;
    like( $row, qr{DBIx::Class::ResultSet}, 'rs data has package name' );
    like( $row, qr{my_table},               'rs data has query' );
    like( $row, qr{qux},                    'rs data has column value' );
}

{
    my $row      = np( DBIx::Class::ResultSet::HRI->new );
    my $filtered = np( $row );
    diag $row;
    like(
        $row,
        qr{DBIx::Class::ResultSet::HRI},
        'HRI rs data has package name'
    );
    like( $row, qr{my_table}, 'HRI rs data has query' );
    like( $row, qr{qux},      'HRI rs data has column value' );
}
done_testing();
