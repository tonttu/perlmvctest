package Project;
use strict;
use base 'HoursDB';

Project->set_up_table('projects');
Project->has_many(users => [ 'ProjectsUsers' => 'user' ]);
Project->has_many(tasks => 'Task');

Project->set_sql(hours => "SELECT SUM(hours) FROM tasks WHERE project = ?");
sub hours {
	my $self = shift;
	$self->sql_hours->select_val($self->id) || 0;
}

1;
