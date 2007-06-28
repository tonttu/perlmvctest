package Task;
use strict;
use base 'HoursDB';

Task->set_up_table('tasks');
Task->has_a(user => 'User');
Task->set_date_fields(qw(modified));

1;
