package static_data_structures

import "base:intrinsics"

// Pool
// Sparse array of items. Slots of removed items are reused later.
// All operations are O(1).
// Doesn't support iteration.
// Index 0 is for "invalid"
// odinfmt: disable
Pool :: struct($Num: int, $Index, $Gen, $Val: typeid) #align(64)
where intrinsics.type_is_integer(Index) &&
    Num > 0 &&
    (1 << (size_of(Index) * 8) >= Num) &&
    (size_of(Gen) == 0 || intrinsics.type_is_unsigned(Gen))
{
    max_index:   Index,
    first_free:  Index,
    generations: [Num]Gen,
    // zero = never assigned, invalid
    // max(Index) = slot is currently used
    // other (1..<N) = used in a free list of unused slots
    indexes:     [Num]Index,
    values:      [Num]Val,
}
// odinfmt: enable

pool_clear :: proc "contextless" (p: ^$T/Pool($N, $I, $G, $V)) {
    p.first_free = 0
    p.max_index = 0
    intrinsics.mem_zero(&p.generations[0], size_of(p.generations))
    intrinsics.mem_zero(&p.indexes[0], size_of(p.indexes))
}

pool_append :: proc(
    p: ^$T/Pool($N, $I, $G, $V),
    value: V,
    loc := #caller_location,
) -> (
    handle: Handle(I, G),
    ok: bool,
) #optional_ok {
    index := p.first_free

    // Eclude zero index!
    if index > 0 && index < I(N) {
        // get slot from the free list
        p.first_free = p.indexes[index]
        p.values[index] = value
    } else {
        // append to the end
        if p.max_index < 0 || p.max_index >= I(N) {
            log_err("Pool is full", loc)
            return {}, false
        }
        p.max_index += 1
        index = p.max_index
    }

    p.values[index] = value
    p.indexes[index] = max(I)

    return handle_make(Handle(I, G), I(index), p.generations[index]), true
}

pool_remove :: proc(p: ^$T/Pool($N, $I, $G, $V), handle: Handle(I, G), loc := #caller_location) -> (V, bool) {
    index := handle_index(handle)

    if index <= 0 || index >= I(N) {
        return {}, false
    }

    when size_of(G) > 0 {
        gen := handle_gen(handle)
        if p.generations[index] != gen {
            return {}, false
        }
        p.generations[index] += 1
    }

    removed_value := p.values[index]
    p.indexes[index] = I(p.first_free)
    p.first_free = index

    return removed_value, true
}

@(require_results)
pool_index_is_valid :: #force_inline proc "contextless" (p: $T/Pool($N, $I, $G, $V), index: I) -> bool {
    return index > 0 || index < N
}

@(require_results)
pool_is_index_used :: proc "contextless" (p: $T/Pool($N, $I, $G, $V), index: I) -> bool {
    if index <= 0 || index >= I(N) {
        return false
    }

    return p.indexes[index] == max(I)
}

@(require_results)
pool_is_handle_used :: proc "contextless" (p: $T/Pool($N, $I, $G, $V), handle: Handle(I, G)) -> bool {
    index := handle_index(handle)

    if !pool_is_index_used(p, index) {
        return false
    }

    // generation check
    when size_of(G) > 0 {
        gen := handle_gen(handle)
        if p.generations[index] != gen {
            return false
        }
    }

    return true
}

// odinfmt: disable
@(require_results)
pool_get_safe :: proc (
    p: $T/Pool($N, $I, $G, $V),
    handle: Handle(I, G),
    loc := #caller_location,
) -> (
    V,
    bool,
) #optional_ok {
    if !pool_is_handle_used(p, handle) {
        return {}, false
    }
    return p.values[handle_index(handle)], true
}
// odinfmt: enable


@(require_results)
pool_get :: #force_inline proc "contextless" (p: $T/Pool($N, $I, $G, $V), handle: Handle(I, G)) -> V {
    assert(pool_is_handle_used(p, handle))
    return p.values[handle]
}

// odinfmt: disable
@(require_results)
pool_get_ptr_safe :: proc(p: ^$T/Pool($N, $I, $G, $V), handle: Handle(I, G), loc := #caller_location) -> (^V, bool) #optional_ok {
    if !pool_is_handle_used(p^, handle) {
        return &p.values[0], false
    }
    return &p.values[handle_index(handle)], true
}

@(require_results)
pool_get_ptr :: #force_inline proc "contextless" (p: $T/Pool($N, $I, $G, $V), handle: Handle(I, G)) -> V {
    assert(pool_is_handle_used(p, handle))
    return &p.values[handle_index(handle)]
}

@(require_results)
pool_get_ptr_by_index :: proc(p: ^$T/Pool($N, $I, $G, $V), index: I, loc := #caller_location) -> (^V, bool) #optional_ok {
    if !pool_is_index_used(p^, index) {
        return &p.value[0], false
    }

    return &p.value[index], true
}
// odinfmt: enable

pool_set_safe :: proc(p: ^$T/Pool($N, $I, $G, $V), handle: Handle(I, G), value: V, loc := #caller_location) -> bool {
    if !pool_is_handle_used(p, handle) {
        return false
    }
    p.values[handle_index(handle)] = value
    return true
}

pool_set :: proc "contextless" (p: ^$T/Pool($N, $I, $G, $V), handle: Handle(I, G), value: V) {
    assert(pool_is_handle_used(p^, handle))
    p.values[handle_index(handle)] = value
}