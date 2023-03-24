module wire

// ConsumeFixed32 parses b as a little-endian uint32, reporting its len
pub fn consume_fixed32(b []u8) !(u32, int) {
	mut v := u32(0)
	if b.len < 4 {
		return err_truncated
	}
	v = u32(b[0]) << 0 | u32(b[1]) << 8 | u32(b[2]) << 16 | u32(b[3]) << 24
	return v, 4
}

// append_fixed32 appends v to b as a little-endian uin
pub fn append_fixed32(mut b []u8, v u32) []u8 {
	b << [u8(v >> 0), u8(v >> 8), u8(v >> 16), u8(v >> 24)]
	return b
}

// size_fixed32 returns the encoded size of a fixed32; which is alway
pub fn size_fixed32() int {
	return 4
}
