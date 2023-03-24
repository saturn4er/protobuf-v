module wire

// consume_field_value parses a field value and returns its length.
// This assumes that the field Number and wire Type have already been parsed.
// This returns a negative length upon an error (see ParseError).
//
// When parsing a group, the length includes the end group marker and
// the end group is verified to match the starting field number.
pub fn consume_field_value(num Number, typ Type, b []u8) !int {
	match typ {
		.varint {
			_, n := consume_varint(b)!
			return n
		}
		.fixed32 {
			_, n := consume_fixed32(b)!
			return n
		}
		.fixed64 {
			_, n := consume_fixed64(b)!
			return n
		}
		.bytes {
			_, n := consume_bytes(b)!
			return n
		}
		.start_group {
			mut n0 := b.len
			mut b2 := b.clone()
			for {
				num2, typ2, mut n := consume_tag(b2)!
				b2 = b2[n..]
				if typ2 == Type.end_group {
					if num != num2 {
						return err_end_group
					}
					return n0 - b2.len
				}
				n = consume_field_value(num2, typ2, b2)!
				b2 = b2[n..]
			}
		}
		.end_group {
			return err_end_group
		}
	}

	return err_reserved
}

// consume_field parses an entire field record (both tag and value) and ret
pub fn consume_field(b []u8) !(Number, Type, int) {
	mut num, typ, n := consume_tag(b)!
	mut m := consume_field_value(num, typ, b[n..])!
	return num, typ, n + m
}
