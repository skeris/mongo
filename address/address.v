module address

import net

const default_port = "27017"


// Address is a network address. It can either be an IP address or a DNS name.
type Address = string

// Network is the network protocol for this address. In most cases this will be
// "tcp" or "unix".
pub fn (a Address) network() string {
	if a.ends_with('sock') {
		return 'unix'
	}

	return 'tcp'
}

pub fn (a Address) string() string {
	if a.len == 0 {
		return ''
	}

	mut s := a.to_lower()

	if a.network() != 'unix' {
		_, port := net.split_address(a) or {
			return s + ':' + default_port
		}
		
		if port == 0 {
			return s + ':' + default_port
		}
	}

	return s
}