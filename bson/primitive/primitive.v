// Package primitive contains types similar to V primitives for BSON types that do not have direct
// V primitive representations.
module primitive

// Binary represents a BSON binary value.
struct Binary {
	Subtype byte
	Data    []byte
}

// Equal compares bp to bp2 and returns true if they are equal.
fn (bp Binary) Equal(bp2 Binary) bool {
	if bp.Subtype != bp2.Subtype {
		return false
	}
	return bytes.Equal(bp.Data, bp2.Data)
}