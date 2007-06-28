package Application;
use strict;

our @ISA = qw(Base);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless $self, $class;
}

sub set_vars {
	my $self = shift;
	$self->SUPER::set_vars();
	$$self{'vars'}{'admin'} = $$self{'admin'};
}

# Halutaan näyttää shared/default jos erityistä sivua ei löydy
sub default_view {
	my $self = shift;
	$self->SUPER::default_view();
	$self->SUPER::setview('shared/normal') unless @{$self->getview($$self{'render'}->[1])};
}

sub before_action {
	my $self = shift;
	if ($$self{'logged'} = $$self{'session'}->param('logged')) {
		$$self{'user'} = User->retrieve($$self{'session'}->param('user_id'));
		$$self{'admin'} = $$self{'user'} && $$self{'user'}->admin;
	}

	# Vaaditaan kirjautuminen kaikkialle muualle paitsi /users/login:iin
	unless ($$self{'logged'}) {
		if ($$self{'name'} ne 'users') {
			# TODO: tallenna nykyinen tila, jotta voidaan palata siihen kirjautumisen jälkeen
			$$self{'action'} = undef;
			$self->redirect('/users/login');
		} elsif ($$self{'action'} ne 'login') {
			$$self{'action'} = 'login';
		}
	}
}

sub after_action {
	my $self = shift;
	my $vars = $$self{'vars'};
	my $ses = $$self{'session'};

	# Projects
	if (my $pr = $$self{'active_project'}) {
		$ses->param('project', ($$vars{'project'} = $pr)->id);
	} elsif ($pr = $ses->param('project')) {
		$$vars{'project'} = Project->retrieve($pr);
	}
	@{$$vars{'projects_active'}} = Project->search(completed => 0);
	@{$$vars{'projects_completed'}} = Project->search(completed => 1);

	# Tasks
	if (my $task = $$self{'active_task'}) {
		$ses->param('task', ($$vars{'task'} = $task)->id);
	} elsif ($task = $ses->param('task')) {
		$$vars{'task'} = Task->retrieve($task);
	}
	@{$$vars{'tasks'}} = $$vars{'project'} ? $$vars{'project'}->tasks : [];
}

sub get_index {
	my $self = shift;
	$$self{'session'}->param('project', undef);
}

1;
