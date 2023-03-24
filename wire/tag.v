module wire

import math

// encode_tag encodes the field Number and wire Type into its unified form.
pub fn encode_tag(num Number, typ Type) u64 {
	return u64(num) << 3 | u64(i8(typ) & 7)
}

// decode_tag decodes the field Number and wire Type from its unified form.
// The Number is -1 if the decoded field number overflows int32.
// Other than overflow, this does not check for field number validity.
pub fn decode_tag(x u64) !(Number, Type) {
	if x >> 3 > u64(math.max_i32) {
		return Number(-1), Type.varint
	}
	return int(x >> 3), wire_type(i8(x & 7))!
}

// consume_tag parses b as a varint-encoded tag, reporting its length.
pub fn consume_tag(b []u8) !(Number, Type, int) {
	mut v, n := consume_varint(b)!
	mut num, typ := decode_tag(v)!
	if num < min_valid_number {
		return err_field_number
	}
	return num, typ, n
}

// append_tag encodes num and typ as a varint-encoded tag and appends it to b.
pub fn append_tag(mut b []u8, num Number, typ Type) []u8 {
	return append_varint(mut b, encode_tag(num, typ))
}

pub fn size_tag(num Number) int {
	return size_varint(encode_tag(num, Type.varint))
}
