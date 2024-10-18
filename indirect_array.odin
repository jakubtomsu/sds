package sds

import "base:intrinsics"

/*
Indirect Array ("Handle Map")

Linear array which can be addressed with a handle.
Zero initialized is valid cleared state.
Uses a pool to remap handles into raw indexes.
All operations are O(1).
Note: the `intrinsics.type_field_type` is ugly, but I don't think there is any other way.
*/
Indirect_Array :: struct($Num: int, $Val: typeid, $Handle: typeid) where Num > 0 {
    len:           i32,
    pool:          Pool(Num, intrinsics.type_field_type(Handle, "index"), Handle),
    indexes:       [Num]intrinsics.type_field_type(Handle, "index"),
    data:          [Num]Val,
    invalid_value: Val, // returned when get_ptr fails
}

indirect_array_clear :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H)) {
    a.len = 0
    pool_zero(&a.pool)
    intrinsics.mem_zero(&a.indexes[a], size_of(a))
}

@(require_results)
indirect_array_slice :: #force_inline proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H)) -> []V {
    return a.data[:a.len]
}

@(require_results)
indirect_array_has_index :: #force_inline proc "contextless" (a: $T/Indirect_Array($N, $V, $H), #any_int index: int) -> bool {
    return index >= 0 && i32(index) < a.len
}

@(require_results)
indirect_array_has_handle :: proc "contextless" (a: $T/Indirect_Array($N, $V, $H), handle: H) -> bool {
    return pool_has_handle(a.pool, handle)
}

// Warning: doesn't clear previous value!
@(require_results)
indirect_array_append_empty :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), loc := #caller_location) -> (handle: H, ok: bool) #optional_ok {
    index := a.len
    if int(index) >= N {
        return {}, false
    }
    handle = pool_append(&a.pool, auto_cast index, loc) or_return

    a.indexes[index] = handle.index
    a.len += 1
    return handle, true
}

indirect_array_append :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), value: V, loc := #caller_location) -> (handle: H, ok: bool) #optional_ok {
    index := a.len
    handle = indirect_array_append_empty(a, loc) or_return
    a.data[index] = value
    return handle, true
}

indirect_array_remove :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), handle: H, loc := #caller_location) -> bool {
    item_index := pool_remove(&a.pool, handle, loc) or_return

    assert_contextless(item_index >= 0 && i32(item_index) < a.len, "", loc)

    last_item_index := a.len - 1

    // Ignore when removing last value
    if uint(last_item_index) < uint(len(a.data)) {
        last_pool_index := a.indexes[last_item_index]
        // Swap item data
        a.data[item_index] = a.data[last_item_index]
        // Point to the swapped handle
        a.indexes[item_index] = last_pool_index

        a.pool.data[last_pool_index] = item_index

        // Note: do we want to run this in release mode? Adds a bit of safety for almost no cost.
        a.data[last_item_index] = {}
        a.indexes[last_item_index] = max(intrinsics.type_field_type(H, "index"))
    }

    a.len -= 1
    return true
}

@(require_results)
indirect_array_get_safe :: proc "contextless" (a: $T/Indirect_Array($N, $V, $H), handle: H, loc := #caller_location) -> (value: V, ok: bool) #optional_ok {
    item_index := pool_get_safe(a.pool, handle) or_return

    if item_index < 0 || i32(item_index) >= a.len {
        return {}, false
    }

    assert_contextless(a.indexes[item_index] == handle.index, "Sanity check", loc)
    return a.data[item_index], true
}

@(require_results)
indirect_array_get :: #force_inline proc "contextless" (a: $T/Indirect_Array($N, $V, $H), handle: H, loc := #caller_location) -> V {
    return a.data[pool_get(a.pool, handle, loc)]
}

@(require_results)
indirect_array_get_ptr_safe :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), handle: H, loc := #caller_location) -> (ptr: ^V, ok: bool) #optional_ok {
    item_index := pool_get_safe(a.pool, handle) or_return

    if item_index < 0 || i32(item_index) >= a.len {
        return &a.invalid_value, false
    }

    assert_contextless(a.indexes[item_index] == handle.index, "Sanity check", loc)
    return &a.data[item_index], true
}

@(require_results)
indirect_array_get_ptr :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), handle: H, loc := #caller_location) -> ^V {
    return &a.data[pool_get(a.pool, handle, loc)]
}

indirect_array_set_safe :: proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), handle: H, value: V, loc := #caller_location) -> bool {
    item_index := pool_get_safe(a.pool, handle) or_return

    if item_index < 0 || i32(item_index) >= a.len {
        return  false
    }

    assert_contextless(a.indexes[item_index] == handle.index, "Sanity check", loc)
    a.data[item_index] = value
    return true
}

indirect_array_set :: #force_inline proc "contextless" (a: ^$T/Indirect_Array($N, $V, $H), handle: H, value: V, loc := #caller_location) {
    a.data[pool_get(a.pool, handle, loc)] = value
}
