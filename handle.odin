package static_data_structures

// Invalid handle is zero ({})
// GEN could be assigned to struct{}
// odinfmt: disable
Handle :: struct($INDEX, $GEN: typeid) #raw_union
    where intrinsics.type_is_integer(INDEX) &&
    (size_of(GEN) == 0 || intrinsics.type_is_unsigned(GEN))
{
    index: INDEX,
    gen:   GEN,
}
// odinfmt: enable