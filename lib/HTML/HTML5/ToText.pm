package HTML::HTML5::ToText;

use 5.010;
use common::sense;
use utf8;

BEGIN {
	$HTML::HTML5::ToText::AUTHORITY = 'cpan:TOBYINK';
	$HTML::HTML5::ToText::VERSION   = '0.001';
}

use Moose;
with 'MooseX::Traits';

has '+_trait_namespace' => (
	default => join('::', __PACKAGE__, 'Trait'),
	);

use XML::LibXML::PrettyPrint;

BEGIN
{
	my @empty  = qw[base basefont bgsound br canvas col command embed frame hr
	                img is index keygen link meta param];
	my @inline = qw[a abbr area b bdi bdo big button cite code dfn em font i
	                input kbd label mark meter nobr progress q rp rt ruby s
	                samp small span strike strong sub sup time tt u var wbr];
	my @block  = qw[address applet article aside audio blockquote body caption
	                center colgroup datalist del dir div dd details dl dt
	                fieldset figcaption figure footer form frameset h1 h2 h3
	                h4 h5 h6 head header hgroup html iframe ins legend li
	                listing map marquee menu nav noembed noframes noscript
	                object ol optgroup option p select section source summary
	                table tbody td tfoot th thead title tr track ul video];
	
	{
		no strict 'refs';
		*{ uc $_ } = sub { (shift)->_inline($_, @_) }
			foreach @inline;
		*{ uc $_ } = sub { (shift)->_block($_, @_) }
			foreach @block;
		*{ uc $_ } = sub { (shift)->_empty($_, @_) }
			foreach @empty;
	}
}

sub process
{
	my ($self, $node) = @_;
	$self = $self->new unless ref $self;
	
	if ($node->nodeName eq '#document')
	{
		$node = $node->documentElement->cloneNode(1);
	}
	else
	{
		$node = $node->cloneNode(1);
	}
	
	XML::LibXML::PrettyPrint->strip_whitespace($node);
	
	my $elem = uc $node->nodeName;
	return $self->$elem($node);
}

sub textnode
{
	my ($self, $node, %args) = @_;
	return $node->data;
}

sub _inline
{
	my ($self, $func, $node, %args) = @_;
	
	my $return = '';
	foreach my $kid ($node->childNodes)
	{
		if ($kid->nodeName eq '#text')
		{
			$return .= $self->textnode($kid, %args);
		}
		else
		{
			my $elem = uc $kid->nodeName;
			$return .= $self->$elem($kid, %args);
		}
	}
	
	$return;
}

sub _block
{
	my ($self, $func, $node, %args) = @_;
	
	my $return = '';
	foreach my $kid ($node->childNodes)
	{
		if ($kid->nodeName eq '#text')
		{
			$return .= $self->textnode($kid, %args);
		}
		else
		{
			my $elem = uc $kid->nodeName;
			my $str  = $self->$elem($kid, %args);
			
			$return = "\n" if ($str !~ /^\n/ and $return eq '');
			$return .= $str;
		}
	}
	$return .= "\n" unless $return =~ /\n$/;
	
	$return;
}

sub _empty
{
	return '';
}

__PACKAGE__
__END__

=head1 NAME

HTML::HTML5::ToText - convert HTML to plain text

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=HTML-HTML5-ToText>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

