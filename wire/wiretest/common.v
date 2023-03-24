module wiretest

import encoding.hex

interface AppendOp {
	append(mut buf []u8)
	size() int
}

interface ConsumeAssertser {
	consume_assert(buf []u8) !int
}

pub struct TestCase {
	name            ?string
	initial_data    []u8       = []
	append_ops      []AppendOp = []
	want_raw        []u8       = []
	consume_asserts []ConsumeAssertser = []
}

pub fn run_tests(tests ...TestCase) ! {
	for i, test in tests {
		run_test_case(i, test)!
	}
}

fn run_test_case(testI int, test TestCase) ! {
	mut test_prefix := 'test ${testI}'
	if test.name != none {
		test_prefix += ', name: ${test.name}'
	}
	test_prefix += ': '

	println('${test_prefix}')
	defer {
		println('${test_prefix} passed')
	}
	mut data := test.initial_data.clone()
	mut prev_size := data.len
	for op in test.append_ops {
		op.append(mut data)
		assert data.len == prev_size + op.size(), '${test_prefix} append op size mismatch'
		prev_size = data.len
	}
	assert hex.encode(data) == hex.encode(test.want_raw), '${test_prefix} data mismatch'
	mut offset := int(0)
	for consume_assert in test.consume_asserts {
		offset += consume_assert.consume_assert(data[offset..])!
	}
}
