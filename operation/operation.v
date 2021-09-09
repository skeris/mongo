module operation

import description
import driver
import session
import writeconcern

// Operation is used to execute an operation. It contains all of the common code required to
// select a server, transform an operation into a command, write the command to a connection from
// the selected server, read a response from that connection, process the response, and potentially
// retry.
//
// The required fields are Database, CommandFn, and Deployment. All other fields are optional.
//
// While an Operation can be constructed manually, drivergen should be used to generate an
// implementation of an operation instead. This will ensure that there are helpers for constructing
// the operation and that this type isn't configured incorrectly.
struct Operation {

	// CommandFn is used to create the command that will be wrapped in a wire message and sent to
	// the server. This function should only add the elements of the command and not start or end
	// the enclosing BSON document. Per the command API, the first element must be the name of the
	// command to run. This field is required.
	command_fn fn([]byte, description.SelectedServer) ?[]byte

	// Deployment is the MongoDB Deployment to use. While most of the time this will be multiple
	// servers, commands that need to run against a single, preselected server can use the
	// SingleServerDeployment type. Commands that need to run on a preselected connection can use
	// the SingleConnectionDeployment type.
	deployment driver.Deployment

	// Database is the database that the command will be run against. This field is required.
	database string

	// Client is the session used with this operation. This can be either an implicit or explicit
	// session. If the server selected does not support sessions and Client is specified the
	// behavior depends on the session type. If the session is implicit, the session fields will not
	// be encoded onto the command. If the session is explicit, an error will be returned. The
	// caller is responsible for ensuring that this field is nil if the Deployment does not support
	// sessions.
	client *session.Client

	// WriteConcern is the write concern used when running write commands. This field should not be
	// set for read operations. If this field is set, it will be encoded onto the commands sent to
	// the server.
	write_concern *writeconcern.WriteConcern
}

fn (op Operation) validate() {
	if op.command_fn == 0 {
		return error('no command_fn')
	}

	if op.deployment == 0 {
		return error('no deployment')
	}

	if op.database == "" {
		return error('no database')
	}

	if op.client != 0 && !writeconcern.ack_write(op.write_concern) {
		return error('session provided for an unacknowledged write')
	}
}

// Execute runs this operation. The scratch parameter will be used and overwritten (potentially many
// times), this should mainly be used to enable pooling of byte slices.
fn (op Operation) execute(ctx context.Context, scratch []byte) ? {
	op.validate() or {
		return err
	}

	if op.client != 0 {
		
	}
}