module wire

// append_string appends v to b as a length-prefixed bytes va
pub fn append_string(mut b []u8, v string) []u8 {
	b = append_varint(mut b, u64(v.len))
	b << v.bytes()

	return b
}

// consume_string parses b as a length-prefixed bytes value, reporting its len
pub fn consume_string(b []u8) !(string, int) {
	mut bb, n := consume_bytes(b)!
	return bb.bytestr(), n
}

// size_string returns the encoded size of a length-prefixed string
pub fn size_string(bytes_len int) int {
	return size_varint(u64(bytes_len)) + bytes_len
}
