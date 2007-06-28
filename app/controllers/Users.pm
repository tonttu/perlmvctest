package Users;
use strict;

use base qw(Application);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless $self, $class;
}

sub get_index {
}

sub post_login {
	my $self = shift;
	my ($login, $passwd) = @{$$self{'cgi'}->Vars}{'login', 'passwd'};
	my $user;

	if ($login && $passwd && ($user = User->search(login => $login, password => User->passwd_hash($passwd))->first)) {
		$$self{'session'}->param('user_id', $user->id());
		$$self{'session'}->param('logged', 1);
		$self->flash_notice("Login successful");
		$self->redirect('/users');
	} else {
		$self->flash_error_now("Wrong username or password");
	}
}

sub get_login {
}

1;
