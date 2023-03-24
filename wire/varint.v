module wire

import math.bits

// consume_varint parses b as a varint-encoded uint64, reporting its len
pub fn consume_varint(b []u8) !(u64, int) {
	mut y := u64(0)
	mut v := u64(0)
	byte_last_bit := u64(0x80)

	if b.len <= 0 {
		return err_truncated
	}
	v = u64(b[0])
	if v < 0x80 {
		return v, 1
	}
	v -= 0x80

	if b.len <= 1 {
		return err_truncated
	}
	y = u64(b[1])
	v += y << 7
	if y < byte_last_bit {
		return v, 2
	}
	v -= byte_last_bit << 7

	if b.len <= 2 {
		return err_truncated
	}
	y = u64(b[2])
	v += y << 14
	if y < byte_last_bit {
		return v, 3
	}
	v -= byte_last_bit << 14

	if b.len <= 3 {
		return err_truncated
	}
	y = u64(b[3])
	v += y << 21
	if y < byte_last_bit {
		return v, 4
	}
	v -= byte_last_bit << 21

	if b.len <= 4 {
		return err_truncated
	}
	y = u64(b[4])
	v += y << 28
	if y < byte_last_bit {
		return v, 5
	}
	v -= byte_last_bit << 28

	if b.len <= 5 {
		return err_truncated
	}
	y = u64(b[5])
	v += y << 35
	if y < byte_last_bit {
		return v, 6
	}
	v -= byte_last_bit << 35

	if b.len <= 6 {
		return err_truncated
	}
	y = u64(b[6])
	v += y << 42
	if y < byte_last_bit {
		return v, 7
	}
	v -= byte_last_bit << 42

	if b.len <= 7 {
		return err_truncated
	}
	y = u64(b[7])
	v += y << 49
	if y < byte_last_bit {
		return v, 8
	}
	v -= byte_last_bit << 49

	if b.len <= 8 {
		return err_truncated
	}
	y = u64(b[8])
	v += y << 56
	if y < byte_last_bit {
		return v, 9
	}
	v -= byte_last_bit << 56

	if b.len <= 9 {
		return err_truncated
	}
	y = u64(b[9])
	v += y << 63
	if y < 2 {
		return v, 10
	}
	return err_overflow
}

// append_varint appends v to b as a varint-encoded uin
pub fn append_varint(mut b []u8, v u64) []u8 {
	if v == 0 {
		b << u8(0)
		return b
	}
	mut v1 := v

	for v1 > 0 {
		mut next_byte := u8(v1 & 0x7f)
		v1 >>= 7
		if v1 != 0 {
			next_byte |= 0x80
		}
		b << next_byte
	}

	return b
}

// size_varint returns the encoded size of a var
pub fn size_varint(v u64) int {
	return int(9 * u32(bits.len_64(v)) + 64) / 64
}
