module session

// TransactionState indicates the state of the transactions FSM.
type TransactionState =  u8

const (
	none =  TransactionState(0)
	starting =  TransactionState(1)
	in_progress = TransactionState(2)
	committed = TransactionState(3)
	aborted = TransactionState(4)
)

// Client is a session for clients to run commands.
struct Client {
	aborting bool
	committing bool

	transaction_state TransactionState
}

// StartCommand updates the session's internal state at the beginning of an operation. This must be called before
// server selection is done for the operation as the session's state can impact the result of that process.
fn (c &Client) start_command() ? {
	if c != nil {
		// If we're executing the first operation using this session after a transaction, we must ensure that the session
		// is not pinned to any resources.
		if !c.transaction_running() && !c.committing && !c.aborting {
			c.ClearPinnedResources() // fixme
		}
	}
}

// TransactionRunning returns true if the client session has started the transaction
// and it hasn't been committed or aborted
fn (c &Client) transaction_running() bool {
	return c != 0 && (c.transaction_state == starting || c.transaction_state == in_progress)
}