module wire

pub const (
	min_valid_number      = Number(1)
	first_reserved_number = Number(19000)
	last_reserved_number  = Number(19999)
	max_valid_number      = Number((i32(1) << 29) - 1)
)

pub type Number = int

// is_valid reports whether the field number is semantically va
pub fn (n Number) is_valid() bool {
	return wire.min_valid_number <= n
		&& (n < wire.first_reserved_number || wire.last_reserved_number < n)
		&& n <= wire.max_valid_number
}
