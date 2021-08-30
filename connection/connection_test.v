module connection

import context

fn test_main() {
	conn := new('127.0.0.1')
	conn.connect(context.todo())
}