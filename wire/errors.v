module wire

// err_code_truncated    = {}
//    err_code_field_number = {}
//    err_code_overflow = {}
//    err_code_reserved = {}
//    err_code_end_group = {}

const (
	err_truncated    = error('truncated')
	err_field_number = error('invalid field number')
	err_overflow     = error('variable length integer overflow')
	err_reserved     = error('cannot parse reserved wire type')
	err_end_group    = error('mismatching end group marker')

	err_parse        = error('parse error')
)
