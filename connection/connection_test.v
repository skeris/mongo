module connection

import context

fn test_main() {
	mut oldctx := context.background()
	mut ctx, cancel := context.with_cancel(mut &oldctx)
	println(ctx)
	cancel()
	// mut conn := new('127.0.0.1')
	// mut ctx := context.todo()
	// conn.connect(&ctx)
	// assert conn.conn != 0
}