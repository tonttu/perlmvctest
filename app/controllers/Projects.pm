package Projects;
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
	$$self{'active_project'} = Project->insert($self->getvars('project.'));
	$self->flash_notice_now("Project created")
}

sub get_create {
}

sub post_modify {
	my $self = shift;
	$self->get_modify(@_);
	if (my $p = $$self{'active_project'}) {
		# Koska post-datassa ei liiku ollenkaan ei-klikatut checkboxit
		$p->set(completed => 0);
		$p->set(%{$self->getvars('project.')});
		$p->update() ? $self->flash_notice_now("Project saved")
					 : $self->flash_error_now("Error while saving project");
	}
}

sub get_modify {
	my ($self, $id) = @_;
	$$self{'active_project'} = Project->retrieve($id);
}

sub before_action {
	my $self = shift;
	$self->SUPER::before_action();
	$$self{'session'}->param('task', undef);
}

1;
