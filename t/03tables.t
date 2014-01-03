use Test::More tests => 1;
use HTML::HTML5::Parser;
use HTML::HTML5::ToText;

my $dom = HTML::HTML5::Parser->load_html(IO => \*DATA);
my $str = HTML::HTML5::ToText
	-> with_traits(qw/TextFormatting RenderTables/)
	-> new
	-> process($dom);

is $str, <<'OUTPUT';
Here is a table:
=======================================
TABLE: Foo to the bar to the foo to
the bar to the foo to the bar to the
foo to the bar to the foo to the bar
to the foo to the bar to the foo.
=======================================
    A    |    B     |    C     |   D  
=======================================
    1    | Big                 | i    
         | monkey-ass cell!!!  |      
         | 1                   |      
         | 2                   |      
---------| 3                   |-------
    2    | 4                   | ii   
         | 5                   |      
         | 6                   |      
         |                     |      
=======================================
 Here is a nested table:       | World
 =======                       |      
  Hello                        |      
 =======                       |      
=======================================

And here's some other stuff.
=================
 Some content | 
=================

And an empty table
OUTPUT

__DATA__
<p>Here is a table:</p>
<table>
	<caption>Foo to the bar to the foo to the bar to the foo to the bar to the
	foo to the bar to the foo to the bar to the foo to the bar to the foo.</caption>
	<col>
	<colgroup>
		<col span="2">
	</colgroup>
	<thead>
		<tr>
			<th>A</th>
			<th>B</th>
			<th>C</th>
			<th>D</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<th>1</th>
			<td colspan="2" rowspan="2">Big<br>monkey-ass cell!!!<br>1<br>2<br>3<br>4<br>5<br>6</td>
			<td>i</td>
		</tr>
		<tr>
			<th>2</th>
			<td>ii</td>
		</tr>
	</tbody>
	<tbody>
		<tr>
			<td colspan="3">
				<p>Here is a nested table:</p>
				<table><tbody><tr><td>Hello</td></tr></tbody></table>
			</td>
			<td>World</td>
		</tr>
	</tbody>
</table>
<p>And here's some other stuff.</p>
<table>
<tr><td>Some content</td><td></td></tr>
</table>
<p>And an empty table</p>
<table><tr></tr></table>
