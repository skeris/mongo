module connection

import context
import net
import address

struct Connection {
	id string
	addr address.Address
}


// new handles the creation of a connection. It does not connect the connection.
fn new(addr address.Address) &Connection {
	return &Connection{
		id: '',
		addr: addr,
	} 
}

// connect handles the I/O for a connection. It will dial, configure TLS, and perform
// initialization handshakes.
fn (c &Connection) connect(ctx context.Context) {
	_ := dial_tcp_context(ctx, c.addr.string())
}

fn dial_tcp_context(ctx context.Context, addr string) &net.TcpConn {
	mut conn := net.dial_tcp(addr) or {
		println(err)
		panic(err)
	}


	go fn (ctx context.Context, mut conn &net.TcpConn) {
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
	} (ctx,mut conn)

	return conn
}