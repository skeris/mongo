module address

struct Ex {
	input       string
	expected string
}

fn test_main () {
	tests := [
		Ex{"a", "a:27017"},
		Ex{"A", "a:27017"},
		Ex{"A:27017", "a:27017"},
		Ex{"a:27017", "a:27017"},
		Ex{"a.sock", "a.sock"},
	]

	for _, test in tests {
		assert Address(test.input).string() == test.expected
	}
}