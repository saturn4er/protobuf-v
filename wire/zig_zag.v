module wire

// encode_zig_zag encodes an int64 as a zig-zag-encoded uint64.
//
//	Input:  {…, -3, -2, -1,  0, +1, +2, +3, …}
//	Output: {…,  5,  3,  1,  0,  2,  4,  6, …}
pub fn encode_zig_zag(x i64) u64 {
	return u64(x << 1) ^ u64(x >> 63)
}

// decode_zig_zag decodes a zig-zag-encoded uint64 as an int64.
//
//	Input:  {…,  5,  3,  1,  0,  2,  4,  6, …}
//	Output: {…, -3, -2, -1,  0, +1, +2, +3, …}
pub fn decode_zig_zag(x u64) i64 {
	return i64(x >> 1) ^ i64(x) << 63 >> 63
}
