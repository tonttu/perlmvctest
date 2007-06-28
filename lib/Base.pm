package Base;
use strict;

use CGI;
use CGI::Session qw(-ip-match);
use FindBin qw($Bin);

use lib "$Bin/../lib";
use lib "$Bin/../app/models";
use lib "$Bin/../app/controllers";

use Class::Autouse map {/(\w+)\.pm$/; $1} <$Bin/../app/*/*.pm $Bin/../lib/*.pm>;

use base qw(Class::Data::Inheritable);

Base->mk_classdata(Dir => "$Bin/..");
Base->mk_classdata(Env => ($ENV{'HOURS_ENV'} || 'dev'));

# Palauttaa sivupyynnön mukaisen controllerin
sub factory {
	my $self;
	my $cgi = new CGI;
	my %controllers = map {/(\w+)\.pm$/; lc $1 => $1} <$Bin/../app/controllers/*.pm>;
	my @url = split '/', (@ARGV ? $ARGV[0] : $cgi->url(-absolute => 1));
	shift @url;

	if (@url && $controllers{$url[0]}) {
		$self = $controllers{shift @url}->new($cgi);
		$self->action(@url);
	} else {
		$self = $controllers{'application'} ? new Application($cgi) : new Base($cgi);
		$self->action(qw(404));
	}
	$self;
}

sub new {
	my ($class, $cgi) = @_;
	my $self = {
		'cgi' => $cgi,
		'name' => lc $class,
		'headers_printed' => 0,
		'session' => new CGI::Session("driver:MySQL", $cgi, {Handle => HoursDB->db_Main})
	};
	bless $self, $class;
}

# Palauttaa oletus-template-tiedoston määritellylle "ctrl/action":lle
#
# Esim $self->getview('users/index') voisi palauttaa:
#  ['tt', '/opt/foo/app/views/users/index.tt]
sub getview {
	my ($self, $act) = @_;
	my $path = Base->Dir . "/app/views/$act";
	for (sort <$path.*>) {
		/\.([^\.]+)$/;
		return ["$1", $_] if ($self->can("tpl_$1"));
	}
	[];
}

# Suoritetaan itse sivupyyntö ja tulostetaan sivu
sub render {
	my $self = shift;

	$self->before_action;
	$self->set_vars;

	my $act = $$self{'action'};
	my $method = lc $$self{'cgi'}->request_method();

	if ($act) {
		if ($self->can("${method}_$act")) {
			$act = "${method}_$act";
		} elsif ($method ne 'get' && $self->can("get_$act")) {
			$act = "get_$act";
		} else {
			$act = "get_404";
		}
		$self->$act(@$self{'params'});
	}
	$self->after_action;
	$self->default_view unless $$self{'render'};

	my ($type, $param) = @{$$self{'render'}};
	if ($type eq "view") {
		my ($ext, $filename) = @{$self->getview($param)};
		if ($ext && $filename) {
			$ext = "tpl_$ext";
			$self->$ext($filename);
		} else {
			$self->error500("Template not found");
		}
	} elsif ($type eq "redirect") {
		print $$self{'cgi'}->redirect(@{$param});
	} else {
		$self->error500("type is '$type' instead of 'view' of redirect'");
	}
}

# .tt -päätteiset templatet, eli Template Toolkit -tiedostot
sub tpl_tt {
	my $self = shift;
	$self->print_header;

	use Template;
	my $config = {
		INCLUDE_PATH	=> [$self->Dir . "/app/views/", Template::Config->instdir('templates')],
		INTERPOLATE		=> 1,
		POST_CHOMP		=> 1,
		ABSOLUTE		=> 1,
	};

	my $tpl = new Template($config);
	$self->error500($tpl->error()) unless $tpl->process(shift, $$self{'vars'});
}

sub action {
	my $self = shift;
	$$self{'action'} = (@_ && $_[0] =~ /^[A-Za-z]\w*$/) ? shift : 'index';
	@$self{'params'} = @_;
}

sub get_index {
}

sub before_action {
}

sub after_action {
}

# Tätä kutsutaan, jos action ei ole asettanut mitään render-toimintoa
sub default_view {
	my $self = shift;
	$self->setview(@_);
}

sub setview {
	my $self = shift;
	my $tmp = @_ ? shift : $$self{'action'};
	$tmp = $$self{'name'} . "/$tmp" unless $tmp =~ m!/!;
	$$self{'render'} = ['view', $tmp];
}

sub print_header {
	my $self = shift;
	print $$self{'cgi'}->header(
		-charset	=> 'utf-8',
		-cookie		=> $$self{'cgi'}->cookie(CGISESSID => $$self{'session'}->id),
	) unless $$self{'headers_printed'};
	$$self{'headers_printed'} = 1;
}

sub set_vars {
	my $self = shift;
	$$self{'vars'} = {
		flash_error => $$self{'session'}->param('flash_error'),
		flash_notice => $$self{'session'}->param('flash_notice'),
	};
	$$self{'session'}->clear(['flash_error', 'flash_notice']);
}

sub redirect {
	my $self = shift;
	$$self{'render'} = ['redirect', [@_]];
}

sub flash_notice_now {
	my $self = shift;
	$$self{'vars'}{'flash_notice'} .= join " ", @_;
}

sub flash_error_now {
	my $self = shift;
	$$self{'vars'}{'flash_error'} .= join " ", @_;
}

sub flash_notice {
	my $self = shift;
	$$self{'session'}->param('flash_notice', join " ", @_);
}

sub flash_error {
	my $self = shift;
	$$self{'session'}->param('flash_error', join " ", @_);
}

sub get_404 {
	my $self = shift;
	$self->setview('shared/404');
}

sub error500 {
	my $self = shift;
	$self->print_header;
	print "500\n";
	print "@_\n";
}

sub getvars {
	my ($self, $prefix) = @_;
	if (my $l = length($prefix)) {
		my $ret = {};
		for (keys %{$$self{'cgi'}->Vars}) {
			$$ret{substr($_, $l)} = $$self{'cgi'}->Vars->{$_}
				if substr($_, 0, $l) eq $prefix;

		}
		return $ret;
	} else {
		return $$self{'cgi'}->Vars;
	}
}
1;
