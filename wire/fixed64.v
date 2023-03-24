module wire

// consume_fixed64 parses b as a little-endian uint64, reporting its len
pub fn consume_fixed64(b []u8) !(u64, int) {
	if b.len < 8 {
		return err_truncated
	}
	v := u64(b[0]) << 0 | u64(b[1]) << 8 | u64(b[2]) << 16 | u64(b[3]) << 24 | u64(b[4]) << 32 | u64(b[5]) << 40 | u64(b[6]) << 48 | u64(b[7]) << 56
	return v, 8
}

// append_fixed64 appends v to b as a little-endian uin
pub fn append_fixed64(mut b []u8, v u64) []u8 {
	b << [u8(v >> 0), u8(v >> 8), u8(v >> 16), u8(v >> 24), u8(v >> 32), u8(v >> 40), u8(v >> 48),
		u8(v >> 56)]

	return b
}

// size_fixed64  returns the encoded size of a fixed64; which is alway
pub fn size_fixed64() int {
	return 8
}
