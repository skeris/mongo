module connection

import context
import net
import address
import sync

struct Connection {
	id string
	addr address.Address

	connect_done chan i8
	connect_context_made chan i8

	pub mut:
	     conn &net.TcpConn
		 cancel_connect_context context.CancelFn
		 connect_context_mutex &sync.Mutex
}

const empty_cancel = context.CancelFn{}

// new handles the creation of a connection. It does not connect the connection.
fn new(addr address.Address) &Connection {
	mut mx := sync.new_mutex()
	mx.init()
	return &Connection{
		id: '',
		addr: addr,
		conn: 0,
		connect_done: chan i8{},
		connect_context_made: chan i8{},
		connect_context_mutex: mx,
		cancel_connect_context: empty_cancel,
	} 
}

// connect handles the I/O for a connection. It will dial, configure TLS, and perform
// initialization handshakes.
fn (mut c Connection) connect(mut ctx context.Context) {
	defer {c.connect_done.close()}
	// Create separate contexts for dialing a connection and doing the MongoDB/auth handshakes.
	//
	// handshakeCtx is simply a cancellable version of ctx because there's no default timeout that needs to be applied
	// to the full handshake. The cancellation allows consumers to bail out early when dialing a connection if it's no
	// longer required. This is done in lock because it accesses the shared cancelConnectContext field.
	//
	// dialCtx is equal to handshakeCtx if connectTimeoutMS=0. Otherwise, it is derived from handshakeCtx so the
	// cancellation still applies but with an added timeout to ensure the connectTimeoutMS option is applied to socket
	// establishment and the TLS handshake as a whole. This is created outside of the connectContextMutex lock to avoid
	// holding the lock longer than necessary.

	c.connect_context_mutex.@lock()
	handshake_ctx, cancel_connect_context := context.with_cancel(mut ctx)
println(cancel_connect_context) 
	c.cancel_connect_context = cancel_connect_context
	c.connect_context_mutex.unlock()
cancel_connect_context()
	// dial_ctx := handshake_ctx
	// dial_cancel := context.CancelFn{}

	//todo: config timeot
	// if c.config.connectTimeout != 0 {
	// 	dialCtx, dialCancel = context.WithTimeout(handshakeCtx, c.config.connectTimeout)
	// 	defer dialCancel()
	// }
println(handshake_ctx) 
	defer {
		c.connect_context_mutex.@lock()
		mut cancel_fn := &c.cancel_connect_context
		c.cancel_connect_context = empty_cancel
		c.connect_context_mutex.unlock()

		if cancel_fn != empty_cancel {
			println(cancel_fn)
			cancel_fn()
		}
	}

	c.connect_context_made.close()

	// Assign the result of DialContext to a temporary net.Conn to ensure that c.nc is not set in an error case.

	conn := dial_tcp_context(mut ctx, c.addr.string())

	c.conn = conn
	
}

fn dial_tcp_context(mut ctx context.Context, addr string) &net.TcpConn {
	mut conn := net.dial_tcp(addr) or {
		println(err)
		panic(err)
	}


	go fn (mut ctx context.Context, mut conn &net.TcpConn) {
		ch := ctx.done()
		for {
			select {
				_ := <-ch {
					conn.close() or {
						panic(err)
					}
					// returning not to leak the routine
					return
				}
			}
		}
	} (mut ctx,mut conn)

	return conn
}