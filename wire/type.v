module wire

pub enum Type as i8 {
	varint
	fixed64
	bytes
	start_group
	end_group
	fixed32
}

fn wire_type(v i8) !Type {
	$for value in Type.values {
		if i8(value.value) == v {
			return value.value
		}
	}
	return error('invalid type(${v})')
}
