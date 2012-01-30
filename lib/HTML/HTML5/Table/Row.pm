package HTML::HTML5::Table::Row;

use 5.010;
use namespace::autoclean;
use utf8;

use List::Util qw/max/;
use Moose;
use POSIX qw/ceil/;

has node => (
	is        => 'rw',
	isa       => 'Maybe[XML::LibXML::Element]',
	default   => undef,
	);

has cells => (
	is        => 'rw',
	isa       => 'ArrayRef[HTML::HTML5::Table::Cell]',
	default   => sub { [] },
	traits    => [qw/Array/],
	handles   => {
		push_cell   => 'push',
		get_cell    => 'get',
		count_cells => 'count',
		}
	);

has section => (
	is        => 'rw',
	isa       => 'Maybe[HTML::HTML5::Table::Section]',
	default   => undef,
	weak_ref  => 1,
	);

has height => (
	is        => 'ro',
	isa       => 'Num',
	lazy      => 1,
	builder   => '_build_height',
	clearer   => '_clear_height',
	);

after push_cell => sub
{
	my ($self, $cell) = @_;
	$cell->row($self);
};

after push_cell => sub
{
	my ($self) = @_;
	$self->_clear_height;
};

sub _build_height
{
	my ($self) = @_;
	max(map { $_->needs_height } @{ $self->cells });
}

sub to_text
{
	my ($self, $tt) = @_;
	my @lines = map { q{ } } 1..$self->height;
	
	my $prevcell;
	my $trailer = '-';
	
	foreach my $cell (@{ $self->cells })
	{
		next if defined $prevcell && $prevcell == $cell;
		my $lastcell = ($cell == $self->cells->[-1]);
		
		my $n = 0;
		foreach my $c (@{ $cell->all_cols })
		{
			$n += $c->width + 3;
		}
		$n -= 3;

		my @celltext  = split /\r?\n/, $cell->celltext;
		my $skiplines = 0;
		ROW: foreach my $r (@{$cell->all_rows})
		{
			last ROW if $r == $self;
			$skiplines += $r->height + 1;
		}
		
		for my $i (0 .. $#lines)
		{
			my $ct = defined $celltext[$i + $skiplines]
				? sprintf("% -${n}s", $celltext[$i + $skiplines])
				: (' ' x $n);
			$lines[$i] .= $ct;
			$lines[$i] .= ' | ' unless $lastcell;
		}
		
		if (defined (my $final = $celltext[ $skiplines + scalar(@lines) ]))
		{
			$trailer =~ s/\+\-$/| /;
			$trailer .= sprintf("% -${n}s", $final);
			$trailer .= $lastcell ? ' ' : ' |-';
		}
		else
		{
			$trailer .= '-' x $n;
			$trailer .= $lastcell ? '-' : '-+-';
		}
		
		$prevcell = $cell;
	}
	
	my $return = (join "\n", @lines)."\n";
	$return .= $trailer . "\n"
		unless $self == $self->section->rows->[-1];
	
	$return;
}

1;
