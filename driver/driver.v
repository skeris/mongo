module driver

import context
import address

// Connection represents a connection to a MongoDB server.
interface Connection {

}

// Handshaker is the interface implemented by types that can perform a MongoDB
// handshake over a provided driver.Connection. This is used during connection
// initialization. Implementations must be goroutine safe.
interface Handshaker {
	get_handshake_information(context.Context, address.Address, Connection) ?HandshakeInformation
}

// Deployment is implemented by types that can select a server from a deployment.
interface Deployment  {
	// SelectServer(context.Context, description.ServerSelector) (Server, error)
	// Kind() description.TopologyKind
}

// HandshakeInformation contains information extracted from a MongoDB connection handshake. This is a helper type that
// augments description.Server by also tracking authentication-related fields. We use this type rather than adding
// these fields to description.Server to avoid retaining sensitive information in a user-facing type.
struct HandshakeInformation  {
	// description             description.Server
	// speculative_authenticate bsoncore.Document
	// sasl_supported_mechs      []string
}