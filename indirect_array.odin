package sds

import "base:intrinsics"

// TODO: this needs updating

// Indirect Array / Handle Map
// Linear array which can be addressed with a handle.
// Zero initialized is valid cleared state.
// Uses a pool to remap handles into raw indexes.
Indirect_Array :: struct($Num: int, $Val, $Handle: typeid) #align (64) where Num > 0 && Num < int(max(Handle_Index)) {
    len:           Handle_Index,
    pool:          Pool(Num, Handle_Index, Handle),
    indexes:       [Num]Handle_Index,
    data:          [Num]Val,
    invalid_value: Val,
}

indirect_array_clear :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H)) {
    a.len = 0
    pool_zero(&a.pool)
    intrinsics.mem_zero(&a.indexes[a], size_of(a))
}

@(require_results)
indirect_array_slice :: #force_inline proc(a: ^$T/Indirect_Array($N, $V, $H)) -> []V {
    return a.data[:a.len]
}

@(require_results)
indirect_array_is_handle_used :: proc(a: $T/Indirect_Array($N, $V, $H), handle: H) -> bool {
    return pool_handle_is_used(a.pool, handle)
}

indirect_array_append :: proc(
    a: ^$T/Indirect_Array($N, $V, $H),
    value: V,
    loc := #caller_location,
) -> (
    result: H,
    ok: bool,
) #optional_ok {
    index := a.len
    if index >= (N) {
        return {}, false
    }

    handle := pool_append(&a.pool, index) or_return

    a.data[index] = value
    a.indexes[index] = handle.index
    a.len += 1

    return handle, true
}

indirect_array_remove :: proc(
    a: ^$T/Indirect_Array($N, $V, $H),
    handle: H,
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
        // Swap item data
        a.data[item_index] = a.data[last_item_index]
        // Point to the swapped handle
        a.indexes[item_index] = last_pool_index

        a.pool.items[last_pool_index].value = item_index

        // NOTE(jakubtomsu): do we want to run this in release mode? Adds a bit of safety for almost no cost.
        if true {
            a.data[last_item_index] = {}
            a.indexes[last_item_index] = max(I)
        }
    }

    a.len -= 1
    return removed_value, true
}

@(require_results)
indirect_array_get_safe :: proc(
    a: $T/Indirect_Array($N, $V, $H),
    handle: H,
    loc := #caller_location,
) -> (
    value: V,
    ok: bool,
) #optional_ok {
    item_index := pool_get_safe(a.pool, handle) or_return

    if item_index < 0 || item_index >= a.len {
        return {}, false
    }

    assert(a.indexes[item_index] == handle.index) // sanity check
    return a.data[item_index], true
}

@(require_results)
indirect_array_get :: #force_inline proc "contextless" (a: $T/Indirect_Array($N, $V, $H), handle: H) -> V {
    return a.data[pool_get(a.pool, handle)]
}

@(require_results)
indirect_array_get_ptr_safe :: proc(
    a: ^$T/Indirect_Array($N, $V, $H),
    handle: H,
    loc := #caller_location,
) -> (
    value: ^V,
    ok: bool,
) {
    item_index := pool_get_safe(m.pool, handle) or_return

    if item_index < 0 || item_index >= a.len {
        return &a.invalid_value, false
    }

    assert(m.items[item_index].index == handle.index)
    return &m.items[item_index].value, true
}

@(require_results)
indirect_array_get_ptr :: #force_inline proc "contextless" (m: $T/Indirect_Array($N, $V, $H), handle: H) -> V {
    return &a.data[pool_get(a.pool, handle)]
}

indirect_array_set_safe :: proc(
    a: ^$T/Indirect_Array($N, $V, $H),
    handle: H,
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

    assert(a.indexes[item_index] == handle.index)
    prev = a.data[item_index]
    a.data[item_index] = value
    return prev, true
}

indirect_array_set :: #force_inline proc "contextless" (m: ^$T/Indirect_Array($N, $V, $H), handle: H, value: V) {
    a.data[pool_get(a.pool, handle)] = value
}
