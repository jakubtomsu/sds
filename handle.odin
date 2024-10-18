package sds

import "base:intrinsics"

/*
Generational Handle

Zero value ({}) means the handle is invalid.
'Gen' can be 'struct{}' to disable generation checks.

Note: using 'distinct' for your custom handles is recommended.
*/
Handle :: struct(Index, Gen: typeid)
where
    intrinsics.type_is_integer(Index) &&
    (intrinsics.type_is_integer(Gen) || size_of(Gen) == 0) {
    index: Index,
    gen:   Gen,
}
