package sds

import "base:builtin"
import "base:runtime"

// Static array
// based on core:container/small_array
// TODO: use i32 everywhere
Array :: struct($N: int, $T: typeid) where N >= 0 {
    data: [N]T `fmt:"len"`,
    len:  int,
}

@(require_results)
array_slice :: #force_inline proc "contextless" (a: ^$A/Array($N, $T)) -> []T {
    return a.data[:a.len]
}

@(require_results)
array_get :: #force_inline proc(a: $A/Array($N, $T), #any_int index: int) -> T {
    assert(index >= 0 && index < a.len)
    return a.data[index]
}

@(require_results)
array_get_ptr :: #force_inline proc(a: $A/Array($N, $T), #any_int index: int) -> ^T {
    assert(index >= 0 && index < a.len)
    return &a.data[index]
}

array_set :: #force_inline proc(a: $A/Array($N, $T), #any_int index: int, value: T) {
    assert(index >= 0 && index < a.len)
    a.data[index] = value
}

array_set_safe :: proc "contextless" (a: $A/Array($N, $T), #any_int index: int, value: T) -> bool {
    if index < 0 || index >= a.len {
        return false
    }
    a.data[index] = value
}

@(require_results)
array_get_safe :: proc "contextless" (a: $A/Array($N, $T), #any_int index: int) -> (T, bool) #optional_ok {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return a.data[index], true
}

array_get_ptr_safe :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int) -> (^T, bool) #optional_ok {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return &a.data[index], true
}

array_has_index :: #force_inline proc "contextless" (a: ^$A/Array, #any_int index: int) {
    return index >= 0 && index < a.len
}

array_resize :: #force_inline proc "contextless" (a: ^$A/Array, #any_int length: int) {
    a.len = clamp(length, 0, builtin.len(a.data))
}

array_append :: proc(a: ^$A/Array($N, $T), item: T, loc := #caller_location) -> int {
    assert(a.len < N, "Reached the array size limit", loc)
    index := a.len
    a.data[index] = item
    a.len += 1
    return index
}

array_append_safe :: proc "contextless" (a: ^$A/Array($N, $T), item: T) -> (int, bool) #optional_ok {
    if a.len < N {
        index := a.len
        a.data[index] = item
        a.len += 1
        return index, true
    }
    return 0, false
}

array_append_elems :: proc "contextless" (a: ^$A/Array($N, $T), items: ..T) -> int {
    n := copy(a.data[a.len:], items[:])
    a.len += n
    return n
}


array_pop_back :: proc(a: ^$A/Array($N, $T), loc := #caller_location) -> T {
    assert(condition = (N > 0 && a.len > 0), loc = loc)
    item := a.data[a.len - 1]
    a.len -= 1
    return item
}

array_pop_back_safe :: proc "contextless" (a: ^$A/Array($N, $T)) -> (item: T, ok: bool) #optional_ok {
    if N > 0 && a.len > 0 {
        item = a.data[a.len - 1]
        a.len -= 1
        ok = true
    }
    return
}

array_ordered_remove :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, a.len)
    if index + 1 < a.len {
        copy(a.data[index:], a.data[index + 1:])
    }
    a.len -= 1
}

array_remove :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, a.len)
    n := a.len - 1
    if index != n {
        a.data[index] = a.data[n]
    }
    a.len -= 1
}

array_inject_at :: proc "contextless" (a: ^$A/Array($N, $T), item: T, #any_int index: int) -> bool {
    if a.len < N && index >= 0 && index <= N {
        a.len += 1
        for i := a.len - 1; i >= index + 1; i -= 1 {
            a.data[i] = a.data[i - 1]
        }
        a.data[index] = item
        return true
    }
    return false
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Static SOA Array
//

Soa_Array :: struct($N: int, $T: typeid) where N >= 0 {
    data: #soa[N]T,
    len:  int,
}

soa_array_set_safe :: proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int, value: T) -> bool {
    if index < 0 || index >= a.len {
        return false
    }
    a.data[index] = value
}

soa_array_slice :: #force_inline proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> #soa[]T {
    return a.data[:a.len]
}

soa_array_has_index :: proc "contextless" (a: ^$A/Soa_Array, #any_int index: int) {
    return index >= 0 && index < a.len
}

@(require_results)
soa_array_get :: proc(a: $A/Soa_Array($N, $T), #any_int index: int) -> T {
    assert(index >= 0 && index < a.len)
    return a.data[index]
}

@(require_results)
soa_array_get_ptr :: proc(a: $A/Soa_Array($N, $T), #any_int index: int) -> ^T {
    assert(index >= 0 && index < a.len)
    return &a.data[index]
}

soa_array_set :: proc(a: $A/Soa_Array($N, $T), #any_int index: int, value: T) {
    assert(index >= 0 && index < a.len)
    a.data[index] = value
}

@(require_results)
soa_array_get_safe :: proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int) -> (T, bool) #optional_ok {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return a.data[index], true
}

@(require_results)
soa_array_get_ptr_safe :: proc(a: ^$A/Soa_Array($N, $T), #any_int index: int) -> (result: #soa^#soa[N]T, ok: bool) #optional_ok {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return &a.data[index], true
}

soa_array_resize :: proc "contextless" (a: ^$A/Soa_Array, #any_int length: int) {
    a.len = clamp(length, 0, builtin.len(a.data))
}

soa_array_append :: proc "contextless" (a: ^$A/Soa_Array($N, $T), item: T) -> bool {
    if a.len < N {
        a.data[a.len] = item
        a.len += 1
        return true
    }
    return false
}

soa_array_pop_back :: proc(a: ^$A/Soa_Array($N, $T), loc := #caller_location) -> T {
    assert(condition = (N > 0 && a.len > 0), loc = loc)
    item := a.data[a.len - 1]
    a.len -= 1
    return item
}

soa_array_pop_back_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> (item: T, ok: bool) {
    if N > 0 && a.len > 0 {
        item = a.data[a.len - 1]
        a.len -= 1
        ok = true
    }
    return
}

soa_array_pop_front_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> (item: T, ok: bool) {
    if N > 0 && a.len > 0 {
        item = a.data[0]
        s := slice(a)
        copy(s[:], s[1:])
        a.len -= 1
        ok = true
    }
    return
}

soa_array_ordered_remove :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, a.len)
    if index + 1 < a.len {
        copy(a.data[index:], a.data[index + 1:])
    }
    a.len -= 1
}

soa_array_remove :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, a.len)
    n := a.len - 1
    if index != n {
        a.data[index] = a.data[n]
    }
    a.len -= 1
}

soa_array_clear :: proc "contextless" (a: ^$A/Soa_Array($N, $T)) {
    a.len = 0
}

soa_array_append_elems :: proc "contextless" (a: ^$A/Soa_Array($N, $T), items: ..T) {
    n := copy(a.data[a.len:], items[:])
    a.len += n
}

soa_array_inject_at :: proc "contextless" (a: ^$A/Soa_Array($N, $T), item: T, #any_int index: int) -> bool {
    if a.len < N && index >= 0 && index <= N {
        a.len += 1
        for i := a.len - 1; i >= index + 1; i -= 1 {
            a.data[i] = a.data[i - 1]
        }
        a.data[index] = item
        return true
    }
    return false
}
