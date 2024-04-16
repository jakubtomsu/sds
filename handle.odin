package static_data_structures

// Invalid handle is zero ({})
// GEN could be assigned to struct{}
// odinfmt: disable
Handle :: struct($Index, $Gen: typeid) #raw_union
    where intrinsics.type_is_integer(Index) &&
    (size_of(Gen) == 0 || intrinsics.type_is_unsigned(Gen))
{
    index: Index,
    gen:   Gen,
}
// odinfmt: enable