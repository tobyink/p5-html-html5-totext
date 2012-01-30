use Test::More skip_all => "there's a method for every HTML element!";
use Test::Pod::Coverage;

my @modules = qw(HTML::HTML5::ToText);
pod_coverage_ok($_, "$_ is covered")
	foreach @modules;
done_testing(scalar @modules);

