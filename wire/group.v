module wire

// append_group appends v to b as group value, with a trailing end group mar
pub fn append_group(mut b []u8, num Number, v []u8) []u8 {
	mut result := b.clone()
	result << v
	return append_varint(mut b, encode_tag(num, Type.end_group))
}

// consume_group parses b as a group value until the trailing end group marker,
// and verifies that the end marker matches the provided num. The value v
// does not contain the end marker, while the length does contain the end marker.
pub fn consume_group(num Number, b []u8) !([]u8, int) {
	n := consume_field_value(num, Type.start_group, b)!
	mut b1 := b.clone()[..n]
	for b1.len > 0 && b1[b1.len - 1] & 0x7f == 0 {
		b1 = b1[..b1.len - 1]
	}
	b1 = b1[..b1.len - size_tag(num)]
	return b1, n
}

// size_group returns the encoded size of a group, given only the length.
pub fn size_group(num_4 Number, n_4 int) int {
	return n_4 + size_tag(num_4)
}
