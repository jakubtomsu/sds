package static_data_structures

// Indirect Array / Handle Map
// Linear array which can be addressed with a handle.
// Zero initialized is valid cleared state.
// Set GEN to struct{} to disable generation counter checking.
// Uses a pool to remap handles into raw indexes.
// odinfmt: disable
Indirect_Array :: struct($NUM: int, $INDEX, $GEN, $VAL: typeid) #align(64)
where intrinsics.type_is_integer(INDEX) &&
    NUM > 0 &&
    (1 << (size_of(INDEX) * 8) >= NUM) &&
    (size_of(GEN) == 0 || intrinsics.type_is_unsigned(GEN))
{
    len: INDEX,
    pool: Pool(NUM, INDEX, GEN, INDEX),
    indexes: [NUM]INDEX,
    values: [NUM]VAL,
    invalid_value: VAL,
}
// odinfmt: enable

indirect_array_clear :: proc "contextless" (a: ^$T/Indirect_Array($N, $I, $G, $V)) {
    a.len = 0
    pool_zero(&a.pool)
    intrinsics.mem_zero(&a.indexes[a], size_of(a))
}

@(require_results)
indirect_array_slice :: #force_inline proc(a: ^$T/Indirect_Array($N, $I, $G, $V)) -> []V {
    return a.values[:a.len]
}

@(require_results)
indirect_array_is_handle_used :: proc(a: $T/Indirect_Array($N, $I, $G, $V), handle: Handle(I, G)) -> bool {
    return pool_handle_is_used(a.pool, handle)
}

indirect_array_append :: proc(
    a: ^$T/Indirect_Array($N, $I, $G, $V),
    value: V,
    loc := #caller_location,
) -> (
    result: Handle(I, G),
    ok: bool,
) #optional_ok {
    index := a.len
    if index >= I(N) {
        return {}, false
    }

    handle := pool_append(&a.pool, index) or_return

    a.values[index] = value
    a.indexes[index] = handle_index(handle)
    a.len += 1

    return handle, true
}

indirect_array_remove :: proc(
    a: ^$T/Indirect_Array($N, $I, $G, $V),
    handle: Handle(I, G),
    loc := #caller_location,
) -> (
    removed_value: V,
    ok: bool,
) #optional_ok {
    item_index := pool_remove(&a.pool, handle) or_return

    assert(item_index >= 0, loc)
    assert(item_index <= a.len, loc)

    last_item_index := a.len - 1
    removed_value = m.items[item_index].value

    // Ignore when removing last value
    if uint(last_item_index) < uint(len(m.items)) {
        last_pool_index := m.items[last_item_index].index
        // Swap item values
        a.values[item_index] = a.values[last_item_index]
        // Point to the swapped handle
        a.indexes[item_index] = last_pool_index

        a.pool.items[last_pool_index].value = item_index

        // NOTE(jakubtomsu): do we want to run this in release mode? Adds a bit of safety for almost no cost.
        if true {
            a.values[last_item_index] = {}
            a.indexes[last_item_index] = max(I)
        }
    }

    a.len -= 1
    return removed_value, true
}

@(require_results)
indirect_array_get_safe :: proc(
    a: $T/Indirect_Array($N, $I, $G, $V),
    handle: Handle(I, G),
    loc := #caller_location,
) -> (
    value: V,
    ok: bool,
) #optional_ok {
    item_index := pool_get_safe(a.pool, handle) or_return

    if item_index < 0 || item_index >= a.len {
        return {}, false
    }

    assert(a.indexes[item_index] == handle_index(handle)) // sanity check
    return a.values[item_index], true
}

@(require_results)
indirect_array_get :: #force_inline proc "contextless" (a: $T/Indirect_Array($N, $I, $G, $V), handle: Handle(I, G)) -> V {
    return a.values[pool_get(a.pool, handle)]
}

@(require_results)
indirect_array_get_ptr_safe :: proc(
    a: ^$T/Indirect_Array($N, $I, $G, $V),
    handle: Handle(I, G),
    loc := #caller_location,
) -> (
    value: ^V,
    ok: bool,
) {
    item_index := pool_get_safe(m.pool, handle) or_return

    if item_index < 0 || item_index >= a.len {
        return &a.invalid_value, false
    }

    assert(m.items[item_index].index == handle_index(handle))
    return &m.items[item_index].value, true
}

@(require_results)
indirect_array_get_ptr :: #force_inline proc "contextless" (m: $T/Indirect_Array($N, $I, $G, $V), handle: Handle(I, G)) -> V {
    return &a.values[pool_get(a.pool, handle)]
}

indirect_array_set_safe :: proc(
    a: ^$T/Indirect_Array($N, $I, $G, $V),
    handle: Handle(I, G),
    value: V,
    loc := #caller_location,
) -> (
    prev: V,
    ok: bool,
) #optional_ok {
    item_index := pool_get_safe(m.pool, handle) or_return

    if item_index < 0 || item_index >= a.len {
        return {}, false
    }

    assert(a.indexes[item_index] == handle_index(handle))
    prev = a.values[item_index]
    a.values[item_index] = value
    return prev, true
}

indirect_array_set :: #force_inline proc "contextless" (m: ^$T/Indirect_Array($N, $I, $G, $V), handle: Handle(I, G), value: V) {
    a.values[pool_get(a.pool, handle)] = value
}
