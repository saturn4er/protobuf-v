module wire

// encode_bool encodes a bool as a uin
pub fn encode_bool(x_3 bool) u64 {
	if x_3 {
		return 1
	}
	return 0
}

// decode_bool decodes a uint64 as a b
pub fn decode_bool(x_2 u64) bool {
	return x_2 != 0
}
