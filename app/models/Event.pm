package Event;
use strict;
use base 'HoursDB';

Event->set_up_table('events');
Event->set_date_fields(qw(modified));

1;
