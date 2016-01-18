use strict;
use warnings;

package DBIx::Class::ResultSet;

use feature qw( state );

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub as_query { \[ 'SELECT * FROM my_table' ] }

sub next {
    state $counter = 0;
    return if $counter == 1;
    ++$counter;
    return DBIx::Class::Row->new;
}

sub result_class { 'MyResultClass' }

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

my $row = np( DBIx::Class::Row->new );
diag np( $row );

my $rs = DBIx::Class::ResultSet->new;
diag np( $rs );

ok( 1 );
done_testing();
