package sds

import "base:intrinsics"

// odinfmt: disable
// Zero value means invalid handle
Handle :: struct(Index, Gen: typeid)
where
    intrinsics.type_is_integer(Index) &&
    (intrinsics.type_is_integer(Gen) || size_of(Gen) == 0)
{
    index: Index,
    gen:   Gen,
}
// odinfmt: enable

Handle8_G8 :: Handle(u8, u8)
Handle16_G16 :: Handle(u16, u16)
Handle32_G32 :: Handle(u32, u32)

Handle8_G0 :: Handle(u8, struct {})
Handle16_G0 :: Handle(u16, struct {})
Handle32_G0 :: Handle(u32, struct {})
