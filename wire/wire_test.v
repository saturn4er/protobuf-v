module wire

import protobuf.wire.wiretest
import encoding.hex
import math

fn new_raw_data_err_asserter[T](raw_data string, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(raw_data)!
		want_raw: hex.decode(raw_data)!
		consume_asserts: [T{
			want_err: err
		}]
	}
}

struct ConsumeFieldAsserter {
	want_err ?IError
	want_num ?Number
	want_typ ?Type
	want_n   ?int
}

fn new_consume_field_error_asserter(err IError) ConsumeFieldAsserter {
	return ConsumeFieldAsserter{
		want_err: err
	}
}

fn new_consume_field_asserter(num Number, typ Type, n int) ConsumeFieldAsserter {
	return ConsumeFieldAsserter{
		want_num: num
		want_typ: typ
		want_n: n
	}
}

fn (c ConsumeFieldAsserter) consume_assert(buf []u8) !int {
	num, typ, n := consume_field(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert c.want_num? == num
	assert c.want_typ? == typ
	assert c.want_n? == n

	return n
}

struct ConsumeVarIntAsserter {
	want_err ?IError
	want_val ?u64
	want_cnt ?int
}

fn (c ConsumeVarIntAsserter) consume_assert(buf []u8) !int {
	val, n := consume_varint(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert c.want_val? == val
	assert c.want_cnt? == n

	return n
}

struct ConsumeTagAsserter {
	want_err  ?IError
	want_num  ?Number
	want_type ?Type
	want_n    ?int
}

fn (c ConsumeTagAsserter) consume_assert(buf []u8) !int {
	num, typ, n := consume_tag(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert c.want_num? == num
	assert c.want_type? == typ
	assert c.want_n? == n

	return n
}

struct ConsumeBytesAsserter {
	want_err   ?IError
	want_bytes ?[]u8
	want_n     int
}

fn (c ConsumeBytesAsserter) consume_assert(buf []u8) !int {
	result, n := consume_bytes(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert c.want_bytes?.len == result.len
	assert c.want_n == n
	for i, b in result {
		assert c.want_bytes?[i] == b
	}

	return n
}

struct ConsumeFixed32Asserter {
	want_err ?IError
	want_val ?u32
}

fn (c ConsumeFixed32Asserter) consume_assert(buf []u8) !int {
	result, n := consume_fixed32(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert 4 == n
	assert c.want_val? == result

	return n
}

struct ConsumeFixed64Asserter {
	want_err ?IError
	want_val ?u64
}

fn (c ConsumeFixed64Asserter) consume_assert(buf []u8) !int {
	result, n := consume_fixed64(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert 8 == n
	assert c.want_val? == result

	return n
}

struct ConsumeStringAsserter {
	want_err ?IError
	want_val ?string
	want_n   int
}

fn (c ConsumeStringAsserter) consume_assert(buf []u8) !int {
	result, n := consume_string(buf) or {
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert c.want_val?.len == result.len
	assert c.want_val? == result
	assert c.want_n == n

	return n
}

struct ConsumeGroupAsserter {
	in_num Number

	want_err ?IError
	want_val []u8
	want_n   int
}

fn (c ConsumeGroupAsserter) consume_assert(buf []u8) !int {
	result, n := consume_group(c.in_num, buf) or {
		assert c.want_err != none
		assert c.want_err? == err
		return 0
	}
	assert c.want_err == none
	assert c.want_val.len == result.len
	assert c.want_val == result
	assert c.want_n == n

	return n
}

struct AppendRaw {
	val []u8
}

fn (a AppendRaw) append(mut buf []u8) {
	buf << a.val
}

fn (a AppendRaw) size() int {
	return a.val.len
}

struct AppendTagOp {
	num Number
	typ Type
}

fn (a AppendTagOp) append(mut buf []u8) {
	append_tag(mut buf, a.num, a.typ)
}

fn (a AppendTagOp) size() int {
	return size_tag(a.num)
}

struct AppendVarIntOp {
	val u64
}

fn (a AppendVarIntOp) append(mut buf []u8) {
	append_varint(mut buf, a.val)
}

fn (a AppendVarIntOp) size() int {
	return size_varint(a.val)
}

struct AppendFixed32Op {
	val u32
}

fn (a AppendFixed32Op) append(mut buf []u8) {
	append_fixed32(mut buf, a.val)
}

fn (_ AppendFixed32Op) size() int {
	return size_fixed32()
}

struct AppendFixed64Op {
	val u64
}

fn (a AppendFixed64Op) append(mut buf []u8) {
	append_fixed64(mut buf, a.val)
}

fn (_ AppendFixed64Op) size() int {
	return size_fixed64()
}

struct AppendBytesOp {
	val []u8
}

fn (a AppendBytesOp) append(mut buf []u8) {
	append_bytes(mut buf, a.val)
}

fn (a AppendBytesOp) size() int {
	return size_bytes(a.val.len)
}

struct AppendGroupOp {
	num Number
	val []u8
}

fn (a AppendGroupOp) append(mut buf []u8) {
	append_group(mut buf, a.num, a.val)
}

fn (a AppendGroupOp) size() int {
	return size_group(a.num, a.val.len)
}

struct AppendStringOp {
	val string
}

fn (a AppendStringOp) append(mut buf []u8) {
	append_string(mut buf, a.val)
}

fn (a AppendStringOp) size() int {
	return size_string(a.val.bytes().len)
}

fn test_field() {
	tests := [
		wiretest.TestCase{
			name: 'empty data'
			consume_asserts: [
				new_consume_field_error_asserter(err_truncated),
			]
		},
		wiretest.TestCase{
			name: 'end group before start group'
			append_ops: [
				AppendTagOp{5, Type.end_group},
			]
			want_raw: hex.decode('2c')!
			consume_asserts: [
				new_consume_field_error_asserter(err_end_group),
			]
		},
		wiretest.TestCase{
			name: 'correct groups'
			append_ops: [
				AppendTagOp{1, Type.start_group},
				AppendTagOp{22, Type.start_group},
				AppendTagOp{333, Type.start_group},
				AppendTagOp{4444, Type.start_group},
				AppendTagOp{4444, Type.end_group},
				AppendTagOp{333, Type.end_group},
				AppendTagOp{22, Type.end_group},
				AppendTagOp{1, Type.end_group},
			]
			want_raw: hex.decode('0bb301eb14e39502e49502ec14b4010c')!
			consume_asserts: [
				new_consume_field_asserter(1, Type.start_group, 16),
			]
		},
		wiretest.TestCase{
			name: 'incorrect groups(missing 4444 end)'
			append_ops: [
				AppendTagOp{1, Type.start_group},
				AppendTagOp{22, Type.start_group},
				AppendTagOp{333, Type.start_group},
				AppendTagOp{4444, Type.start_group},
				AppendTagOp{333, Type.end_group},
				AppendTagOp{22, Type.end_group},
				AppendTagOp{1, Type.end_group},
			]
			want_raw: hex.decode('0bb301eb14e39502ec14b4010c')!
			consume_asserts: [
				new_consume_field_error_asserter(err_end_group),
			]
		},
		wiretest.TestCase{
			name: 'incorrect groups(truncated)'
			append_ops: [
				AppendTagOp{1, Type.start_group},
				AppendTagOp{22, Type.start_group},
				AppendTagOp{333, Type.start_group},
				AppendTagOp{4444, Type.start_group},
				AppendTagOp{4444, Type.end_group},
				AppendTagOp{333, Type.end_group},
				AppendTagOp{22, Type.end_group},
			]
			want_raw: hex.decode('0bb301eb14e39502e49502ec14b401')!
			consume_asserts: [
				new_consume_field_error_asserter(err_truncated),
			]
		},
		wiretest.TestCase{
			name: 'incorrect field number'
			append_ops: [
				AppendTagOp{1, Type.start_group},
				AppendTagOp{22, Type.start_group},
				AppendTagOp{333, Type.start_group},
				AppendTagOp{4444, Type.start_group},
				AppendTagOp{0, Type.varint},
				AppendTagOp{4444, Type.end_group},
				AppendTagOp{333, Type.end_group},
				AppendTagOp{22, Type.end_group},
				AppendTagOp{1, Type.end_group},
			]
			want_raw: hex.decode('0bb301eb14e3950200e49502ec14b4010c')!
			consume_asserts: [
				new_consume_field_error_asserter(err_field_number),
			]
		},
		wiretest.TestCase{
			name: 'correct groups from raw data'
			initial_data: hex.decode('c3b80208959aef3a6515cd5b07d90715cd5b0700000000924d0568656c6c6fcb830658959aef3ae54b15cd5b07998f3c15cd5b070000000092ff892f07676f6f64627965cc8306c4b802')!
			want_raw: hex.decode('c3b80208959aef3a6515cd5b07d90715cd5b0700000000924d0568656c6c6fcb830658959aef3ae54b15cd5b07998f3c15cd5b070000000092ff892f07676f6f64627965cc8306c4b802')!
			consume_asserts: [
				ConsumeFieldAsserter{none, 5000, Type.start_group, 74},
			]
		},
	]

	wiretest.run_tests(...tests) or { println('test error: ${err}') }
}

fn new_var_int_test_case(value u64, want_raw string, want_cnt int) !wiretest.TestCase {
	return wiretest.TestCase{
		append_ops: [AppendVarIntOp{
			val: value
		}]
		want_raw: hex.decode(want_raw)!
		consume_asserts: [
			ConsumeVarIntAsserter{
				want_val: value
				want_cnt: want_cnt
			},
		]
	}
}

fn new_var_int_raw_data_err_test_case(raw_data string, want_err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(raw_data)!
		want_raw: hex.decode(raw_data)!
		consume_asserts: [ConsumeVarIntAsserter{
			want_err: want_err
		}]
	}
}

fn new_var_int_raw_data_test_case(raw_data string, want_val u64, want_cnt int) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(raw_data)!
		want_raw: hex.decode(raw_data)!
		consume_asserts: [
			ConsumeVarIntAsserter{
				want_val: want_val
				want_cnt: want_cnt
			},
		]
	}
}

fn test_varint() ! {
	tests := [
		new_var_int_raw_data_err_test_case('', err_truncated)!,
		new_var_int_raw_data_err_test_case('80', err_truncated)!,
		new_var_int_raw_data_err_test_case('8080', err_truncated)!,
		new_var_int_raw_data_err_test_case('808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('80808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('8080808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('808080808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('80808080808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('8080808080808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('808080808080808080', err_truncated)!,
		new_var_int_raw_data_err_test_case('80808080808080808080', err_overflow)!,
		new_var_int_raw_data_err_test_case('ffffffffffffffffff02', err_overflow)!,
		new_var_int_raw_data_err_test_case('8180808080808080808000', err_overflow)!,
		new_var_int_test_case(0x0, '00', 1)!,
		new_var_int_test_case(0x1, '01', 1)!,
		new_var_int_test_case(0x7f, '7f', 1)!,
		new_var_int_test_case(0x7f + 1, '8001', 2)!,
		new_var_int_test_case(0x3fff, 'ff7f', 2)!,
		new_var_int_test_case(0x3fff + 1, '808001', 3)!,
		new_var_int_test_case(0x1fffff, 'ffff7f', 3)!,
		new_var_int_test_case(0x1fffff + 1, '80808001', 4)!,
		new_var_int_test_case(0xfffffff, 'ffffff7f', 4)!,
		new_var_int_test_case(0xfffffff + 1, '8080808001', 5)!,
		new_var_int_test_case(0x7ffffffff, 'ffffffff7f', 5)!,
		new_var_int_test_case(0x7ffffffff + 1, '808080808001', 6)!,
		new_var_int_test_case(0x3ffffffffff, 'ffffffffff7f', 6)!,
		new_var_int_test_case(0x3ffffffffff, 'ffffffffff7f', 6)!,
		new_var_int_test_case(0x3ffffffffff + 1, '80808080808001', 7)!,
		new_var_int_test_case(0x1ffffffffffff, 'ffffffffffff7f', 7)!,
		new_var_int_test_case(0x1ffffffffffff + 1, '8080808080808001', 8)!,
		new_var_int_test_case(0xffffffffffffff, 'ffffffffffffff7f', 8)!,
		new_var_int_test_case(0xffffffffffffff + 1, '808080808080808001', 9)!,
		new_var_int_test_case(0x7fffffffffffffff, 'ffffffffffffffff7f', 9)!,
		new_var_int_test_case(0x7fffffffffffffff + 1, '80808080808080808001', 10)!,
		new_var_int_test_case(math.max_u64, 'ffffffffffffffffff01', 10)!,
		new_var_int_raw_data_test_case('01', 0x1, 1)!,
		new_var_int_raw_data_test_case('8100', 1, 2)!,
		new_var_int_raw_data_test_case('818000', 1, 3)!,
		new_var_int_raw_data_test_case('81808000', 1, 4)!,
		new_var_int_raw_data_test_case('8180808000', 1, 5)!,
		new_var_int_raw_data_test_case('818080808000', 1, 6)!,
		new_var_int_raw_data_test_case('81808080808000', 1, 7)!,
		new_var_int_raw_data_test_case('8180808080808000', 1, 8)!,
		new_var_int_raw_data_test_case('818080808080808000', 1, 9)!,
		new_var_int_raw_data_test_case('81808080808080808000', 1, 10)!,
	]
	wiretest.run_tests(...tests)!
}

fn new_tag_raw_data_err_test_case(data string, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(data)!
		want_raw: hex.decode(data)!
		consume_asserts: [ConsumeTagAsserter{
			want_err: err
		}]
	}
}

fn new_tag_test_case(num Number, typ Type, data string, n int) !wiretest.TestCase {
	return wiretest.TestCase{
		append_ops: [AppendTagOp{
			num: num
			typ: typ
		}]
		want_raw: hex.decode(data)!
		consume_asserts: [
			ConsumeTagAsserter{
				want_num: num
				want_type: typ
				want_n: n
			},
		]
	}
}

fn test_tag() {
	test_cases := [
		new_tag_raw_data_err_test_case('', err_truncated)!,
		new_tag_test_case(1, Type.fixed32, '0d', 1)!,
		new_tag_test_case(first_reserved_number, Type.bytes, 'c2a309', 3)!,
		new_tag_test_case(last_reserved_number, Type.start_group, 'fbe109', 3)!,
		// Testing this
		new_tag_test_case(max_valid_number, Type.varint, 'f8ffffff0f', 5)!,
		wiretest.TestCase{
			append_ops: [AppendTagOp{
				num: 0
				typ: Type.fixed32
			}]
			want_raw: hex.decode('05')!
			consume_asserts: [ConsumeTagAsserter{
				want_err: err_field_number
			}]
		},
	]
	wiretest.run_tests(...test_cases)!
}

fn new_string_raw_data_err_test_case(data string, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: data.bytes()
		want_raw: data.bytes()
		consume_asserts: [ConsumeStringAsserter{
			want_err: err
		}]
	}
}

fn new_string_raw_data_test_case(data string, want_val string, want_n int) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(data)!
		want_raw: hex.decode(data)!
		consume_asserts: [
			ConsumeStringAsserter{
				want_val: want_val
				want_n: want_n
			},
		]
	}
}

fn new_string_test_case(val string, want_raw []u8, want_cnt int) !wiretest.TestCase {
	return wiretest.TestCase{
		append_ops: [AppendStringOp{
			val: val
		}]
		want_raw: want_raw
		consume_asserts: [
			ConsumeStringAsserter{
				want_val: val
				want_n: want_cnt
			},
		]
	}
}

fn concat_bytes(vals ...[]u8) []u8 {
	mut result := []u8{}
	for val in vals {
		result << val
	}

	return result
}

fn test_string() {
	// hex encoded 0x05 byte concatenated with "hello"
	tests := [
		new_string_raw_data_err_test_case('', err_truncated)!,
		new_string_raw_data_err_test_case('01', err_truncated)!,
		new_string_raw_data_err_test_case('04000000', err_truncated)!,
		new_string_raw_data_test_case('00', '', 1)!,
		new_string_test_case('hello', concat_bytes([u8(5)], 'hello'.bytes()), 6)!,
		new_string_test_case('hello'.repeat(50), concat_bytes([u8(0xfa), 1], 'hello'.repeat(50).bytes()),
			252)!,
	]

	wiretest.run_tests(...tests)!
}

fn new_bytes_raw_data_err_test_case(data []u8, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: data
		want_raw: data
		consume_asserts: [ConsumeBytesAsserter{
			want_err: err
		}]
	}
}

fn new_bytes_raw_data_test_case(raw_data string, want_val string, want_n int) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(raw_data)!
		want_raw: hex.decode(raw_data)!
		consume_asserts: [
			ConsumeBytesAsserter{
				want_bytes: hex.decode(want_val)!
				want_n: want_n
			},
		]
	}
}

fn new_bytes_test_case(bytes []u8, want_raw []u8, want_cnt int) !wiretest.TestCase {
	return wiretest.TestCase{
		append_ops: [AppendBytesOp{
			val: bytes
		}]
		want_raw: want_raw
		consume_asserts: [
			ConsumeBytesAsserter{
				want_bytes: bytes
				want_n: want_cnt
			},
		]
	}
}

fn test_bytes() {
	// hex encoded 0x05 byte concatenated with "hello"
	tests := [
		new_bytes_raw_data_err_test_case([], err_truncated)!,
		new_bytes_raw_data_err_test_case([u8(1)], err_truncated)!,
		new_bytes_raw_data_err_test_case(concat_bytes([u8(0x85), 0x80, 0], 'hell'.bytes()),
			err_truncated)!,
		new_bytes_raw_data_test_case('00', '', 1)!,
		new_bytes_test_case('hello'.bytes(), concat_bytes([u8(5)], 'hello'.bytes()), 6)!,
		new_bytes_test_case('hello'.repeat(50).bytes(), concat_bytes([u8(0xfa), 0x1],
			'hello'.repeat(50).bytes()), 252)!,
		new_bytes_test_case(concat_bytes([u8(0x85), 0x80, 0x0], 'hello'.bytes()), concat_bytes([
			u8(0x8), 0x85, 0x80, 0x0], 'hello'.bytes()), 9)!,
	]

	wiretest.run_tests(...tests)!
}

fn new_fixed32_raw_data_err_test_case(data []u8, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: data
		want_raw: data
		consume_asserts: [ConsumeFixed32Asserter{
			want_err: err
		}]
	}
}

fn new_fixed32_test_case(val u32, want_raw string) !wiretest.TestCase {
	return wiretest.TestCase{
		append_ops: [AppendFixed32Op{
			val: val
		}]
		want_raw: hex.decode(want_raw)!
		consume_asserts: [
			ConsumeFixed32Asserter{
				want_val: val
			},
		]
	}
}

fn test_fixed32() {
	tests := [
		new_fixed32_raw_data_err_test_case([], err_truncated)!,
		new_fixed32_raw_data_err_test_case([u8(0), 0, 0], err_truncated)!,
		new_fixed32_test_case(0, '00000000')!,
		new_fixed32_test_case(math.max_u32, 'ffffffff')!,
		new_fixed32_test_case(0xf0e1d2c3, 'c3d2e1f0')!,
	]

	wiretest.run_tests(...tests)!
}

fn new_fixed64_raw_data_err_test_case(data string, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: hex.decode(data)!
		want_raw: hex.decode(data)!
		consume_asserts: [ConsumeFixed64Asserter{
			want_err: err
		}]
	}
}

fn new_fixed64_test_case(val u64, want_raw string) !wiretest.TestCase {
	return wiretest.TestCase{
		append_ops: [AppendFixed64Op{
			val: val
		}]
		want_raw: hex.decode(want_raw)!
		consume_asserts: [
			ConsumeFixed64Asserter{
				want_val: val
			},
		]
	}
}

fn test_fixed64() {
	// hex encoded 0x05 byte concatenated with "hello"
	tests := [
		new_fixed64_raw_data_err_test_case('', err_truncated)!,
		new_fixed64_raw_data_err_test_case('00000000000000', err_truncated)!,
		new_fixed64_test_case(0, '0000000000000000')!,
		new_fixed64_test_case(math.max_u64, 'ffffffffffffffff')!,
		new_fixed64_test_case(0xf0e1d2c3b4a59687, '8796a5b4c3d2e1f0')!,
	]

	wiretest.run_tests(...tests)!
}

fn new_group_raw_data_err_test_case(data []u8, err IError) !wiretest.TestCase {
	return wiretest.TestCase{
		initial_data: data
		want_raw: data
		consume_asserts: [ConsumeGroupAsserter{
			want_err: err
		}]
	}
}

fn test_group() {
	tests := [
		wiretest.TestCase{
			consume_asserts: [ConsumeGroupAsserter{
				want_err: err_truncated
			}]
		},
		wiretest.TestCase{
			name: 'invalid field number'
			append_ops: [AppendTagOp{0, Type.start_group}]
			want_raw: hex.decode('03')!
			consume_asserts: [ConsumeGroupAsserter{
				want_err: err_field_number
			}]
		},
		wiretest.TestCase{
			name: 'invalid group end tag'
			append_ops: [AppendTagOp{2, Type.end_group}]
			want_raw: hex.decode('14')!
			consume_asserts: [ConsumeGroupAsserter{
				in_num: 1
				want_err: err_end_group
			}]
		},
		wiretest.TestCase{
			name: 'group with 0 fields'
			append_ops: [AppendTagOp{1, Type.end_group}]
			want_raw: hex.decode('0c')!
			consume_asserts: [ConsumeGroupAsserter{
				in_num: 1
				want_n: 1
			}]
		},
		wiretest.TestCase{
			name: 'group with 1 field'
			append_ops: [AppendTagOp{5, Type.fixed32}, AppendFixed32Op{0xf0e1d2c3},
				AppendTagOp{5, Type.end_group}]
			want_raw: hex.decode('2dc3d2e1f02c')!
			consume_asserts: [ConsumeGroupAsserter{
				in_num: 5
				want_val: hex.decode('2dc3d2e1f0')!
				want_n: 6
			}]
		},
		wiretest.TestCase{
			name: 'group with 1 field'
			append_ops: [AppendTagOp{5, Type.fixed32}, AppendFixed32Op{0xf0e1d2c3},
				AppendTagOp{5, Type.end_group}]
			want_raw: hex.decode('2dc3d2e1f02c')!
			consume_asserts: [ConsumeGroupAsserter{
				in_num: 5
				want_val: hex.decode('2dc3d2e1f0')!
				want_n: 6
			}]
		},
		wiretest.TestCase{
			name: 'group with 1 field'
			append_ops: [AppendTagOp{5, Type.fixed32}, AppendFixed32Op{0xf0e1d2c3},
				AppendRaw{hex.decode('ac808000')!}]
			want_raw: hex.decode('2dc3d2e1f0ac808000')!
			consume_asserts: [ConsumeGroupAsserter{
				in_num: 5
				want_val: hex.decode('2dc3d2e1f0')!
				want_n: 9
			}]
		},
	]
	wiretest.run_tests(...tests)!
}
