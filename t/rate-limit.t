use v5.26;
use experimental qw(signatures);

use Test::More;

my $class  = 'WebService::USNationalParkService';
my $method = 'check_rate_limit';

subtest sanity => sub {
	use_ok($class) or BAIL_OUT "$class could not compile: $@";
	can_ok $class, 'new', $method;
	};

subtest rate_limits_without_key => sub {
	my $obj = $class->new( '' );
	isa_ok $obj, $class;
	can_ok $obj, $method;

	my $hash = $obj->$method();
	test_keys_ok( $hash );

	is $hash->{limit}, 0, "'limit' key is zero for bad API key";
	is $hash->{remaining}, 0, "'remaining' key is zero for bad API key";
	};

SKIP: {
skip "NPS_API_KEY not set", 1 unless $ENV{NPS_API_KEY};

subtest rate_limits_with_key => sub {
	my $obj = $class->new( $ENV{NPS_API_KEY} );
	isa_ok $obj, $class;
	can_ok $obj, $method;

	my $hash = $obj->$method();
	test_keys_ok( $hash );

	cmp_ok $hash->{limit}, '>', 0, "'limit' key is greater than 0 for good API key";
	cmp_ok $hash->{remaining}, '>=', 0, "'remaining' key is greater than 0 for good API key";
	};
}

sub test_keys_ok ($hash) {
	isa_ok $hash, ref {};

	foreach my $key ( qw(limit remaining) ) {
		subtest $key => sub {
			ok exists $hash->{$key}, "Key '$key' exists";
			like  $hash->{$key}, qr/\A\d+\z/a, "Value for $key is a positive whole number";
			}
		}
	}

done_testing();
