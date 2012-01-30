use lib "../lib";
use lib "lib";

use HTML::HTML5::Parser;
use HTML::HTML5::ToText;

my $dom = HTML::HTML5::Parser->load_html(IO => \*DATA);
print HTML::HTML5::ToText->with_traits(qw/TextFormatting ShowLinks/)->process( $dom );

__DATA__
<!doctype html>
<title>Foo</title>
<p><b><a href="http://enwp.org/Earth">Hello world</a></b></p>
<p><i>how are you?</i></p>
