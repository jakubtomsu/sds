package sds

// Procedure groups for common operations on datastructures:

slice :: proc {
    array_slice,
    soa_array_slice,
    indirect_array_slice,
}

set :: proc {
    array_set,
    soa_array_set,
    pool_set,
    indirect_array_set,
    queue_set,
    bit_array_set,
}

set_safe :: proc {
    array_set_safe,
    soa_array_set_safe,
    pool_set_safe,
    indirect_array_set_safe,
    queue_set_safe,
    bit_array_set_safe,
}

get :: proc {
    array_get,
    soa_array_get,
    pool_get,
    indirect_array_get,
    queue_get,
    bit_array_get,
}

get_safe :: proc {
    array_get_safe,
    soa_array_get_safe,
    pool_get_safe,
    indirect_array_get_safe,
    queue_get_safe,
    bit_array_get_safe,
}

get_ptr :: proc {
    array_get_ptr,
    soa_array_get_ptr,
    pool_get_ptr,
    indirect_array_get_ptr,
    queue_get_ptr,
}

get_ptr_safe :: proc {
    array_get_ptr_safe,
    soa_array_get_ptr_safe,
    pool_get_ptr_safe,
    indirect_array_get_ptr_safe,
    queue_get_ptr_safe,
}

has_index :: proc {
    array_has_index,
    soa_array_has_index,
    pool_has_index,
    indirect_array_has_index,
}

has_handle :: proc {
    pool_has_handle,
    indirect_array_has_handle,
}

append :: proc {
    array_append,
    soa_array_append,
    pool_append,
    indirect_array_append,
    queue_push_back,
}

append_safe :: proc {
    array_append_safe,
}

append_elems :: proc {
    array_append_elems,
}

append_elems_safe :: proc {
    array_append_elems_safe,
}

pop_back :: proc {
    array_pop_back,
    soa_array_pop_back,
    queue_pop_back,
}

pop_back_safe :: proc {
    array_pop_back_safe,
    soa_array_pop_back_safe,
    queue_pop_back_safe,
}

pop_front :: proc {
    queue_pop_front,
}

pop_front_safe :: proc {
    queue_pop_front_safe,
}

remove :: proc {
    array_remove,
    soa_array_remove,
    pool_remove,
    indirect_array_remove,
}