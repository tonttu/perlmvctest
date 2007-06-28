package User;
use strict;

use Digest::SHA1 qw(sha1_hex);

use base 'HoursDB';

User->set_up_table('users');
User->has_many(tasks => 'Task');
User->has_many(projects => [ ProjectsUsers => 'project' ]);

my $seed = '[M9PY@FB|YN8$-I4 ^T1X4azPN)f<7K5|D,Syp6JnY$L4vWY5<}w;MOT|M8ujG~HLfad1^9%a<KZV<5 h8CtP|jF #0EN2//13tLtHby>!:\8Kq9*awJ"2Pzx s)=l7AW5 ';
sub passwd_hash {
	@_ ? sha1_hex($seed.pop) : undef;
}

sub normalize_column_values {
	my ($self, $h) = @_;
	if (exists $h->{'password'} && $h->{'password'}) {
		$h->{'password'} = passwd_hash($h->{'password'});
	}
}

1;
