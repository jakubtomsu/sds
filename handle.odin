package sds

import "base:intrinsics"

// odinfmt: disable
// Zero value ({}) means invalid handle
Handle :: struct(Index, Gen: typeid)
where
    intrinsics.type_is_integer(Index) &&
    (intrinsics.type_is_integer(Gen) || size_of(Gen) == 0)
{
    index: Index,
    gen:   Gen,
}
// odinfmt: enable
