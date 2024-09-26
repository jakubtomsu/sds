package sds

import "base:intrinsics"

// Pool
// Sparse array of items. Slots of removed items are reused later.
// All operations are O(1).
// Index 0 is for "invalid"
Pool :: struct($Num: int, $Val: typeid, $Handle: typeid) #align (64) where Num > 0 {
	max_index:   int,
	first_free:  int,
	// Indexes:
	// zero = never assigned, invalid
	// max(Handle_Index) = slot is currently used
	// other (1..<N) = used in a free list of unused slots.
	gen_indexes: #soa[Num]Handle,
	data:        [Num]Val,
}

pool_cap :: proc "contextless" (p: $T/Pool($N, $V, $H)) -> int {
	return N
}

pool_clear :: proc "contextless" (p: ^$T/Pool($N, $V, $H)) {
	p.first_free = 0
	p.max_index = 0
	intrinsics.mem_zero(&p.gen_indexes[0], size_of(p.generations))
}

pool_append :: proc(
	p: ^$T/Pool($N, $V, $H),
	value: V,
	loc := #caller_location,
) -> (
	handle: H,
	ok: bool,
) #optional_ok {
	index := p.first_free

	// Eclude zero index!
	if index > 0 && int(index) < N {
		// get slot from the free list
		p.first_free = auto_cast p.indexes[index]
		p.data[index] = value
	} else {
		// append to the end
		if p.max_index < 0 || int(p.max_index) >= N - 1 {
			return {}, false
		}
		p.max_index += 1
		index = p.max_index
	}

	p.data[index] = value
	p.gen_indexes[index].index = max(intrinsics.type_field_type(H, "index"))

	return {index = auto_cast index, gen = p.generations[index]}, true
}

pool_remove :: proc(p: ^$T/Pool($N, $V, $H), handle: H, loc := #caller_location) -> (V, bool) {
	if handle.index <= 0 || int(handle.index) >= N {
		return {}, false
	}

	when size_of(handle.gen) > 0 {
		if p.gen_indexes[handle.index].gen != handle.gen {
			return {}, false
		}
		p.gen_indexes[handle.index].gen += 1
	}

	removed_value := p.data[handle.index]
	p.gen_indexes[handle.index].index = auto_cast p.first_free
	p.first_free = auto_cast handle.index

	return removed_value, true
}

@(require_results)
pool_index_is_valid :: #force_inline proc "contextless" (
	p: $T/Pool($N, $V, $H),
	#any_int index: int,
) -> bool {
	return index > 0 || index < N
}

@(require_results)
pool_has_index :: proc "contextless" (p: $T/Pool($N, $V, $H), #any_int index: int) -> bool {
	if index <= 0 || index >= N {
		return false
	}

	return p.gen_indexes[index].gen == max(intrinsics.type_field_type(H, "index"))
}

@(require_results)
pool_has_handle :: proc "contextless" (p: $T/Pool($N, $V, $H), handle: H) -> bool {
	if !pool_has_index(p, handle.index) {
		return false
	}

	// generation check
	when size_of(handle.gen) > 0 {
		if p.gen_indexes[handle.index].gen != handle.gen {
			return false
		}
	}

	return true
}

@(require_results)
pool_get_safe :: proc(
	p: $T/Pool($N, $V, $H),
	handle: H,
	loc := #caller_location,
) -> (
	V,
	bool,
) #optional_ok {
	if !pool_has_handle(p, handle) {
		return {}, false
	}
	return p.data[handle.index], true
}


@(require_results)
pool_get :: #force_inline proc(p: $T/Pool($N, $V, $H), handle: H) -> V {
	assert(pool_has_handle(p, handle))
	return p.data[handle.index]
}

@(require_results)
pool_get_ptr_safe :: proc(
	p: ^$T/Pool($N, $V, $H),
	handle: H,
	loc := #caller_location,
) -> (
	^V,
	bool,
) #optional_ok {
	if !pool_has_handle(p^, handle) {
		return &p.data[0], false
	}
	return &p.data[handle.index], true
}

@(require_results)
pool_get_ptr :: #force_inline proc(p: ^$T/Pool($N, $V, $H), handle: H) -> ^V {
	assert(pool_has_handle(p^, handle))
	return &p.data[handle.index]
}

// For iteration
@(require_results)
pool_index_get_safe :: proc(p: $T/Pool($N, $V, $H), #any_int index: int) -> (V, H, bool) {
	if !pool_has_index(p, index) {
		return {}, {}, false
	}

	return p.data[index], {auto_cast index, p.gen_indexes[index].gen}, true
}


// For iteration
@(require_results)
pool_index_get_ptr_safe :: proc(p: ^$T/Pool($N, $V, $H), #any_int index: int) -> (^V, H, bool) {
	if !pool_has_index(p^, index) {
		return {}, {}, false
	}

	return &p.data[index], {auto_cast index, p.gen_indexes[index].gen}, true
}


pool_set_safe :: proc(
	p: ^$T/Pool($N, $V, $H),
	handle: H,
	value: V,
	loc := #caller_location,
) -> bool {
	if !pool_has_handle(p, handle) {
		return false
	}
	p.data[handle.index] = value
	return true
}

pool_set :: proc(p: ^$T/Pool($N, $V, $H), handle: H, value: V) {
	assert(pool_has_handle(p^, handle))
	p.data[handle.index] = value
}
