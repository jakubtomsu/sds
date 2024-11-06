package sds

import "base:intrinsics"
import "base:runtime"

/*
Pool (sparse buffer with a free list)

Slots of removed items are kept in a free list and reused later.
All operations are O(1).
Index 0 is for "invalid value".

Iterate with something like this:
```odin
for i in 1..=my_pool.max_index {
    ptr, handle := sds.pool_index_get_ptr_safe(&my_pool, i) or_continue
    // Alternatively use sds.pool_index_get_safe when iterating by value
    // ...
}
```

Note: the reason why this takes a Handle parameter instead of the Index and Gen directly is
to better support distinct handle types, even in return values etc.
*/
Pool :: struct($Num: int, $Val: typeid, $Handle: typeid) where Num > 0{
    max_index:   i32,
    first_free:  i32,
    // Indexes:
    // zero = never assigned, invalid
    // max(Handle_Index) = slot is currently used
    // other (1..<N) = used in a free list of unused slots.
    gen_indexes: #soa[Num]Handle,
    data:        [Num]Val,
}

pool_clear :: proc "contextless" (p: ^$T/Pool($N, $V, $H)) {
    p.first_free = 0
    p.max_index = 0
    intrinsics.mem_zero(&p.gen_indexes, size_of(p.gen_indexes))
}

// Warning: doesn't clear previous value!
@(require_results)
pool_push_empty :: proc "contextless" (p: ^$T/Pool($N, $V, $H), loc := #caller_location) -> (handle: H, ok: bool) #optional_ok {
    index := p.first_free

    // Eclude zero index!
    if index > 0 && int(index) < N {
        // get slot from the free list
        p.first_free = auto_cast p.gen_indexes[index].index
    } else {
        // push to the end
        if p.max_index < 0 || int(p.max_index) >= N - 1 {
            return {}, false
        }
        p.max_index += 1
        index = p.max_index
    }

    p.gen_indexes[index].index = max(intrinsics.type_field_type(H, "index"))

    return {index = auto_cast index, gen = p.gen_indexes[index].gen}, true
}

pool_push :: proc "contextless" (p: ^$T/Pool($N, $V, $H), value: V, loc := #caller_location) -> (handle: H, ok: bool) #optional_ok {
    handle = pool_push_empty(p, loc) or_return
    p.data[handle.index] = value
    return handle, true
}

pool_remove :: proc "contextless" (p: ^$T/Pool($N, $V, $H), handle: H, loc := #caller_location) -> (V, bool) #optional_ok {
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
pool_index_is_valid :: #force_inline proc "contextless" (p: $T/Pool($N, $V, $H), #any_int index: int) -> bool {
    return index > 0 || index < N
}

@(require_results)
pool_has_index :: proc "contextless" (p: $T/Pool($N, $V, $H), #any_int index: int) -> bool {
    if index <= 0 || index >= N {
        return false
    }

    return p.gen_indexes[index].index == max(intrinsics.type_field_type(H, "index"))
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
pool_get :: #force_inline proc "contextless" (p: $T/Pool($N, $V, $H), handle: H, loc := #caller_location) -> V {
    assert_contextless(pool_has_handle(p, handle), "Pool doesn't contain the handle", loc)
    return p.data[handle.index]
}

@(require_results)
pool_get_safe :: proc "contextless" (p: $T/Pool($N, $V, $H), handle: H) -> (V, bool) #optional_ok {
    if !pool_has_handle(p, handle) {
        return {}, false
    }
    return p.data[handle.index], true
}


@(require_results)
pool_get_ptr :: #force_inline proc "contextless" (p: ^$T/Pool($N, $V, $H), handle: H, loc := #caller_location) -> ^V {
    assert_contextless(pool_has_handle(p^, handle), "Pool doesn't contain the handle", loc)
    return &p.data[handle.index]
}

@(require_results)
pool_get_ptr_safe :: proc "contextless" (p: ^$T/Pool($N, $V, $H), handle: H) -> (^V, bool) #optional_ok {
    if !pool_has_handle(p^, handle) {
        return &p.data[0], false
    }
    return &p.data[handle.index], true
}

// For iteration
@(require_results)
pool_index_get_safe :: proc "contextless" (p: $T/Pool($N, $V, $H), #any_int index: int) -> (V, H, bool) {
    if !pool_has_index(p, index) {
        return {}, {}, false
    }

    return p.data[index], {auto_cast index, p.gen_indexes[index].gen}, true
}


// For iteration
@(require_results)
pool_index_get_ptr_safe :: proc "contextless" (p: ^$T/Pool($N, $V, $H), #any_int index: int) -> (^V, H, bool) {
    if !pool_has_index(p^, index) {
        return &p.data[0], {}, false
    }

    return &p.data[index], {auto_cast index, p.gen_indexes[index].gen}, true
}

pool_set :: #force_inline proc "contextless" (p: ^$T/Pool($N, $V, $H), handle: H, value: V, loc := #caller_location) {
    assert_contextless(pool_has_handle(p^, handle), "Pool doesn't contain the handle", loc)
    p.data[handle.index] = value
}

pool_set_safe :: proc "contextless" (p: ^$T/Pool($N, $V, $H), handle: H, value: V) -> bool {
    if !pool_has_handle(p^, handle) {
        return false
    }
    p.data[handle.index] = value
    return true
}
