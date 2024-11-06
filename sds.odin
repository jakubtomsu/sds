package sds

// Procedure groups for common operations on datastructures:

slice :: proc {
    array_slice,
    soa_array_slice,
}

set :: proc {
    array_set,
    soa_array_set,
    pool_set,
    queue_set,
    bit_array_set,
}

set_safe :: proc {
    array_set_safe,
    soa_array_set_safe,
    pool_set_safe,
    queue_set_safe,
    bit_array_set_safe,
}

get :: proc {
    array_get,
    soa_array_get,
    pool_get,
    queue_get,
    bit_array_get,
}

get_safe :: proc {
    array_get_safe,
    soa_array_get_safe,
    pool_get_safe,
    queue_get_safe,
    bit_array_get_safe,
}

get_ptr :: proc {
    array_get_ptr,
    soa_array_get_ptr,
    pool_get_ptr,
    queue_get_ptr,
}

get_ptr_safe :: proc {
    array_get_ptr_safe,
    soa_array_get_ptr_safe,
    pool_get_ptr_safe,
    queue_get_ptr_safe,
}

has_index :: proc {
    array_has_index,
    soa_array_has_index,
    pool_has_index,
}

has_handle :: proc {
    pool_has_handle,
}

push :: proc {
    array_push,
    soa_array_push,
    pool_push,
    queue_push_back,
    spsc_push,
}

push_safe :: proc {
    array_push_safe,
}

push_elems :: proc {
    array_push_elems,
    spsc_push_elems,
}

push_elems_safe :: proc {
    array_push_elems_safe,
}

push_empty :: proc {
	array_push_empty,
	soa_array_push_empty,
	pool_push_empty,
}

pop :: proc {
    array_pop_back,
    soa_array_pop_back,
    queue_pop_back,
    spsc_pop,
}

pop_elems :: proc {
    spsc_pop_elems,
}

pop_safe :: proc {
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
}