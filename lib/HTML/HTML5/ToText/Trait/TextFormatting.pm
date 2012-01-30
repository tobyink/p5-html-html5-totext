package HTML::HTML5::ToText::Trait::TextFormatting;

use 5.010;
use common::sense;
use utf8;

BEGIN {
	$HTML::HTML5::ToText::Trait::TextFormatting::AUTHORITY = 'cpan:TOBYINK';
	$HTML::HTML5::ToText::Trait::TextFormatting::VERSION   = '0.001';
}

use Moose::Role;

around [qw/B STRONG/] => sub {
	my ($orig, $self, @args) = @_;
	my $return = $self->$orig(@args);
	return "*${return}*";
};

around [qw/I EM/] => sub {
	my ($orig, $self, @args) = @_;
	my $return = $self->$orig(@args);
	$return =~ s/ /_/g;
	return "_${return}_";
};

around [qw/BIG/] => sub {
	my ($orig, $self, @args) = @_;
	my $return = $self->$orig(@args);
	uc $return;
};

1;

=head1 NAME

HTML::HTML5::ToText::Trait::TextFormatting - poor man's text formatting

=head1 DESCRIPTION

Adds formatting for *bold*, _italics_ and BIG TEXT.
