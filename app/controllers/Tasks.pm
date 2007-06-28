package Tasks;
use strict;

use base qw(Application);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless $self, $class;
}

sub get_index {
	my $self = shift;
}

sub post_create {
	my $self = shift;
	my $t = $self->getvars('task.');
	$$t{'user'} = $$self{'user'}->id;
	$$t{'project'} = $$self{'session'}->param('project');
	$$self{'active_task'} = Task->insert($t);
	$self->flash_notice_now("Task created")
}

sub post_delete {
	my $self = shift;
	$self->get_modify(@_);
	$$self{'active_task'}->delete;
	$$self{'session'}->param('task', $$self{'active_task'} = undef);
	$self->flash_notice_now("Task deleted")
}

sub get_create {
}

sub post_modify {
	my $self = shift;
	$self->get_modify(@_);
	if (my $t = $$self{'active_task'}) {
		# Koska post-datassa ei liiku ollenkaan ei-klikatut checkboxit
		$t->set(extra_work => 0);
		$t->set(%{$self->getvars('task.')});
		$t->update() ? $self->flash_notice_now("Task saved")
					 : $self->flash_error_now("Error while saving task");
	}
}

sub get_modify {
	my ($self, $id) = @_;
	$$self{'active_task'} = Task->retrieve($id);
}

1;
