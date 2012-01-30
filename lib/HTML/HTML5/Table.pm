package HTML::HTML5::Table;

use 5.010;
use namespace::autoclean;
use utf8;

use HTML::HTML5::ToText;
use HTML::HTML5::Table::Section;
use HTML::HTML5::Table::Head;
use HTML::HTML5::Table::Foot;
use HTML::HTML5::Table::Body;
use HTML::HTML5::Table::Row;
use HTML::HTML5::Table::Col;
use HTML::HTML5::Table::ColGroup;
use HTML::HTML5::Table::Head;
use HTML::HTML5::Table::HeadCell;
use Moose;
use Text::Wrap qw/wrap/;

has node => (
	is        => 'rw',
	isa       => 'Maybe[XML::LibXML::Element]',
	default   => undef,
	);

has caption => (
	is        => 'rw',
	isa       => 'Maybe[XML::LibXML::Element]',
	default   => undef,
	);

has cols => (
	is        => 'rw',
	isa       => 'ArrayRef[HTML::HTML5::Table::Col]',
	default   => sub { [] },
	traits    => [qw/Array/],
	handles   => {
		push_col   => 'push',
		get_col    => 'get',
		count_cols => 'count',
		}
	);

has sections => (
	is        => 'rw',
	isa       => 'ArrayRef[HTML::HTML5::Table::Section]',
	default   => sub { [] },
	traits    => [qw/Array/],
	handles   => {
		push_section   => 'push',
		get_section    => 'get',
		count_sections => 'count',		
		}
	);

sub ensure_col
{
	my ($self, $n) = @_;
	for (0 .. $n)
	{
		$self->cols->[$_] //= HTML::HTML5::Table::Col->new(table => $self);
	}
	$self;
}

after push_section => sub
{
	my ($self, $section) = @_;
	$section->table($self);
};

after push_col => sub
{
	my ($self, $col) = @_;
	$col->table($self);
};

before get_col => sub
{
	my ($self, $n) = @_;
	$self->ensure_col($n);
};

sub parse
{
	my ($self, $node) = @_;
	$self = $self->new unless ref $self;
	
	$self->node($node);
	
	foreach my $kid ($node->childNodes)
	{
		if ($kid->nodeName eq 'caption')
		{
			$self->caption($kid);
		}
		elsif ($kid->nodeName eq 'col')
		{
			$self->push_col( HTML::HTML5::Table::Col->parse($kid) )
		}
		elsif ($kid->nodeName eq 'colgroup')
		{
			$self->push_col( @{ HTML::HTML5::Table::ColGroup->parse($kid)->cols } )
		}
		elsif (my $class = {
			thead   => 'HTML::HTML5::Table::Head',
			tfoot   => 'HTML::HTML5::Table::Foot',
			tbody   => 'HTML::HTML5::Table::Body',
			}->{ $kid->nodeName })
		{
			$self->push_section( $class->parse($kid, table => $self) );
		}
	}
	
	$self;
}

sub to_text
{
	my ($self, $tt) = @_;
	$tt //= HTML::HTML5::ToText->new;
	
	foreach my $section (@{$self->sections})
	{
		foreach my $row (@{$section->rows})
		{
			foreach my $cell (@{$row->cells})
			{
				$cell->calculate_celltext($tt);
			}
		}
	}
	
	my $total_width = 0;
	foreach my $col (@{ $self->cols })
	{
		$total_width += $col->width + 3;
	}
	$total_width -= 1;
	
	my $return = ("=" x $total_width) . "\n";
	
	if ($self->caption)
	{
		local $Text::Wrap::columns = $total_width;
		my $caption_text = $tt->process($self->caption);
		$caption_text =~ s{(\r?\n)+$}{};
		$return = join "\n", ("=" x $total_width), wrap('','',"TABLE: $caption_text"), $return;
	}
	
	foreach my $section (@{$self->sections})
	{
		foreach my $row (@{$section->rows})
		{
			$return .= $row->to_text($tt);
		}
		$return .= ("=" x $total_width) . "\n";
	}
	
	$return
}

1;
