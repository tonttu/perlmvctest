# turha luokka. tämä on vain siksi, että Class::DBI ei osaa n-n -suhteita
package ProjectsUsers;
use strict;
use base 'HoursDB';

ProjectsUsers->table('projects_users');
ProjectsUsers->columns(All => qw/project user/);
ProjectsUsers->has_a(project => 'Project');
ProjectsUsers->has_a(user => 'User');

1;
