package HTML::HTML5::Table::Cell;

use 5.010;
use namespace::autoclean;
use utf8;

use List::Util qw/max/;
use Moose;
use POSIX qw/ceil floor/;

has node => (
	is        => 'rw',
	isa       => 'Maybe[XML::LibXML::Element]',
	default   => undef,
	);

has row => (
	is        => 'rw',
	isa       => 'Maybe[HTML::HTML5::Table::Row]',
	default   => undef,
	weak_ref  => 1,
	);

has col => (
	is        => 'rw',
	isa       => 'Maybe[HTML::HTML5::Table::Col]',
	default   => undef,
	weak_ref  => 1,
	);

has celltext => (
	is        => 'rw',
	isa       => 'Str',
	required  => 0,
	);

has all_rows => (
	is        => 'rw',
	isa       => 'ArrayRef[HTML::HTML5::Table::Row]',
	default   => sub { [] },
	);

has all_cols => (
	is        => 'rw',
	isa       => 'ArrayRef[HTML::HTML5::Table::Col]',
	default   => sub { [] },
	);

sub colspan
{
	my ($self) = @_;
	$self->node->hasAttribute('colspan') ? int($self->node->getAttribute('colspan')) : 1;
}

sub rowspan
{
	my ($self) = @_;
	$self->node->hasAttribute('rowspan') ? int($self->node->getAttribute('rowspan')) : 1;
}

sub calculate_celltext
{
	my ($self, $totext) = @_;
	return $self if $self->celltext;
	$self->celltext(
		join '', map
			{ $totext->process($_, 'no_clone') }
			$self->node->childNodes
		);
	$self;
}

sub needs_width
{
	my ($self) = @_;
	my $max_line = max(map { length $_ } split /\r?\n/, $self->celltext);
	return $max_line if $self->colspan == 1;
	return ceil($max_line / $self->colspan) - 1;
}

sub needs_height
{
	my ($self) = @_;
	my @lines = split /\r?\n/, $self->celltext;
	return scalar(@lines) if $self->rowspan == 1;
	return ceil((scalar(@lines) + 1) / $self->rowspan) - 1;
}

1;
