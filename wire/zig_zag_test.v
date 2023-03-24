module wire

import math

struct ZigZagTest {
	dec i64
	enc u64
}

fn test_zig_zag() {
	tests := [
		ZigZagTest{math.min_i64 + 0, math.max_u64 - 0},
		ZigZagTest{math.min_i64 + 1, math.max_u64 - 2},
		ZigZagTest{math.min_i64 + 2, math.max_u64 - 4},
		ZigZagTest{-3, 5},
		ZigZagTest{-2, 3},
		ZigZagTest{-1, 1},
		ZigZagTest{0, 0},
		ZigZagTest{1, 2},
		ZigZagTest{2, 4},
		ZigZagTest{3, 6},
		ZigZagTest{math.max_i64 - 2, math.max_u64 - 5},
		ZigZagTest{math.max_i64 - 1, math.max_u64 - 3},
		ZigZagTest{math.max_i64 - 0, math.max_u64 - 1},
	]

	for i, tt in tests {
		assert encode_zig_zag(tt.dec) == tt.enc
		assert decode_zig_zag(tt.enc) == tt.dec
	}
}
