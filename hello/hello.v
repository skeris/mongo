module hello

import context

struct Hello {

}

// GetHandshakeInformation performs the MongoDB handshake for the provided connection and returns the relevant
// information about the server. This function implements the driver.Handshaker interface.

fn (h &Hello) get_handshake_information(ctx context.Context)