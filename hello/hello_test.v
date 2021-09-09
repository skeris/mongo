module hello

import driver

fn test_hello_create_positive() {
	h := &Hello{}
	check(h)
	assert h is driver.Handshaker
}
fn check(h driver.Handshaker) {
	println(h)
}