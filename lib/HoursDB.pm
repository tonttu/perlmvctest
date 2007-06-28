package HoursDB;
use strict;

use base 'Class::DBI::mysql';
use Time::Piece::MySQL;
use Config::IniFiles;

my %cfg;
tie %cfg, 'Config::IniFiles', (-file => Base->Dir . '/config/db.ini');

__PACKAGE__->set_db('Main', @{$cfg{Base->Env}}{'dbi', 'user', 'passwd'});

__PACKAGE__->add_trigger(before_create => sub {
		my $self = shift;
		$self->modified(new Time::Piece) if grep(/^modified$/, $self->columns);
		$self->created(new Time::Piece) if grep(/^created$/, $self->columns);
	});

__PACKAGE__->add_trigger(before_update => sub {
		my $self = shift;
		$self->modified(new Time::Piece) if grep(/^modified$/, $self->columns);
	});

sub set_date_fields {
	my $class = shift;
	for (@_) {
		$class->has_a($_ => 'Time::Piece',
			inflate => sub {
				# Jos kannassa on vuotta 1970 pienempi pvm,
				# siitä tulee Time::Piece unix-timestampilla 0!
				Time::Piece->from_mysql_datetime(shift) ||
				new Time::Piece(0) },
			deflate => sub { shift->mysql_datetime });
	}
}
1;
