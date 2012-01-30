package HTML::HTML5::ToText::Trait::ShowLinks;

use 5.010;
use common::sense;
use utf8;

BEGIN {
	$HTML::HTML5::ToText::Trait::TextFormatting::AUTHORITY = 'cpan:TOBYINK';
	$HTML::HTML5::ToText::Trait::TextFormatting::VERSION   = '0.001';
}

use Moose::Role;

around A => sub {
	my ($orig, $self, @args) = @_;
	my $return = $self->$orig(@args);
	my $elem = $args[0];
	return $return unless $elem->hasAttribute('href');
	sprintf("%s <%s>", $return, $elem->getAttribute('href'));
};

1;

=head1 NAME

HTML::HTML5::ToText::Trait::TextFormatting - poor man's text formatting

=head1 DESCRIPTION

Shows the href of C<< <a> >> elements.
