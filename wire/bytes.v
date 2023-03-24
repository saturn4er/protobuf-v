module wire

// consume_bytes parses b as a length-prefixed bytes value, reporting its len
pub fn consume_bytes(b []u8) !([]u8, int) {
	mut m, n := consume_varint(b)!

	if m > b[n..].len {
		return err_truncated
	}

	return b[n..m + u64(n)], n + int(m)
}

// append_bytes appends v to b as a length-prefixed bytes va
pub fn append_bytes(mut b []u8, v []u8) []u8 {
	append_varint(mut b, u64(v.len))
	b << v

	return b
}

// size_bytes returns the encoded size of a length-prefixed bytes va
pub fn size_bytes(n_1 int) int {
	return size_varint(u64(n_1)) + n_1
}
