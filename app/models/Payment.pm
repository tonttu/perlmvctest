package Payment;
use strict;
use base 'HoursDB';

Payment->set_up_table('payments');
Payment->set_date_fields(qw(modified));

1;
