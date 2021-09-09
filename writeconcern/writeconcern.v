module writeconcern

// WriteConcern describes the level of acknowledgement requested from MongoDB for write operations
// to a standalone mongod or to replica sets or to sharded clusters.
struct WriteConcern {
	j bool
	w        interface{}
}


// Acknowledged indicates whether or not a write with the given write concern will be acknowledged.
fn (wc &WriteConcern) acknowledged() bool {
	if wc == 0 || wc.j {
		return true
	}

	match wc.w.type_name() {
		'int' {
			if int(wc.w) == 0 {
				return false
			}
		}
	}

	return true
}

// AckWrite returns true if a write concern represents an acknowledged write
fn ack_write(wc *WriteConcern) bool {
	return wc == nil || wc.acknowledged()
}