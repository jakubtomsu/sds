package static_data_structures

// based on core:container/small_array

import "core:builtin"
import "core:runtime"



////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Static array
//

Array :: struct($N: int, $T: typeid) where N >= 0 {
    data: [N]T,
    len:  int, // (u8 when N < 255 else u64),
}

array_len :: #force_inline proc "contextless" (a: $A/Array) -> int {
    return a.len
}

array_cap :: #force_inline proc "contextless" (a: $A/Array) -> int {
    return builtin.len(a.data)
}

array_slice :: #force_inline proc "contextless" (a: ^$A/Array($N, $T)) -> []T {
    return a.data[:a.len]
}

array_from_slice :: proc "contextless" (a: ^$A/Array($N, $T), data: []T) {
    a.len = copy(a.data[:], data)
}

@(require_results)
array_in_bounds :: #force_inline proc "contextless" (a: $A/Array($N, $T), #any_int index: int) -> bool {
    return index >= 0 && index < a.len
}

@(require_results)
array_get :: #force_inline proc "contextless" (a: $A/Array($N, $T), #any_int index: int) -> T {
    return a.data[index]
}

@(require_results)
array_get_ptr :: #force_inline proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int) -> ^T {
    return &a.data[index]
}

@(require_results)
array_get_safe :: proc "contextless" (a: $A/Array($N, $T), #any_int index: int) -> (T, bool) #no_bounds_check {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return a.data[index], true
}

array_get_ptr_safe :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int) -> (^T, bool) #no_bounds_check {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return &a.data[index], true
}

array_set :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, item: T) {
    a.data[index] = item
}

array_resize :: proc "contextless" (a: ^$A/Array, #any_int length: int) {
    a.len = clamp(length, 0, builtin.len(a.data))
}


array_push_back :: proc "contextless" (a: ^$A/Array($N, $T), item: T) -> bool {
    if a.len < N {
        a.data[a.len] = item
        a.len += 1
        return true
    }
    return false
}

array_push_front :: proc "contextless" (a: ^$A/Array($N, $T), item: T) -> bool {
    if a.len < N {
        a.len += 1
        data := slice(a)
        copy(data[1:], data[:])
        data[0] = item
        return true
    }
    return false
}

array_pop_back :: proc(a: ^$A/Array($N, $T), loc := #caller_location) -> T {
    assert(condition = (N > 0 && a.len > 0), loc = loc)
    item := a.data[a.len - 1]
    a.len -= 1
    return item
}

array_pop_front :: proc(a: ^$A/Array($N, $T), loc := #caller_location) -> T {
    assert(condition = (N > 0 && a.len > 0), loc = loc)
    item := a.data[0]
    s := slice(a)
    copy(s[:], s[1:])
    a.len -= 1
    return item
}

array_pop_back_safe :: proc "contextless" (a: ^$A/Array($N, $T)) -> (item: T, ok: bool) {
    if N > 0 && a.len > 0 {
        item = a.data[a.len - 1]
        a.len -= 1
        ok = true
    }
    return
}

array_pop_front_safe :: proc "contextless" (a: ^$A/Array($N, $T)) -> (item: T, ok: bool) {
    if N > 0 && a.len > 0 {
        item = a.data[0]
        s := slice(a)
        copy(s[:], s[1:])
        a.len -= 1
        ok = true
    }
    return
}

array_ordered_remove :: proc "contextless" (
    a: ^$A/Array($N, $T),
    #any_int index: int,
    loc := #caller_location,
) #no_bounds_check {
    runtime.bounds_check_error_loc(loc, index, a.len)
    if index + 1 < a.len {
        copy(a.data[index:], a.data[index + 1:])
    }
    a.len -= 1
}

array_unordered_remove :: proc "contextless" (
    a: ^$A/Array($N, $T),
    #any_int index: int,
    loc := #caller_location,
) #no_bounds_check {
    runtime.bounds_check_error_loc(loc, index, a.len)
    n := a.len - 1
    if index != n {
        a.data[index] = a.data[n]
    }
    a.len -= 1
}

array_clear :: proc "contextless" (a: ^$A/Array($N, $T)) {
    a.len = 0
}

array_push_back_elems :: proc "contextless" (a: ^$A/Array($N, $T), items: ..T) {
    n := copy(a.data[a.len:], items[:])
    a.len += n
}

array_inject_at :: proc "contextless" (a: ^$A/Array($N, $T), item: T, #any_int index: int) -> bool #no_bounds_check {
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

array_append_elem :: array_push_back
array_append_elems :: array_push_back_elems

array_append :: proc {
    array_push_back,
    array_push_back_elems,
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Static SOA Array
//

Soa_Array :: struct($N: int, $T: typeid) where N >= 0 {
    data: #soa[N]T,
    len:  int,
}

soa_array_len :: #force_inline proc "contextless" (a: $A/Soa_Array) -> int {
    return a.len
}

soa_array_cap :: #force_inline proc "contextless" (a: $A/Soa_Array) -> int {
    return builtin.len(a.data)
}

soa_array_slice :: #force_inline proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> #soa[]T {
    return a.data[:a.len]
}

@(require_results)
soa_array_in_bounds :: #force_inline proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int) -> bool {
    return index >= 0 && index < a.len
}

@(require_results)
soa_array_get :: #force_inline proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int) -> T {
    return a.data[index]
}

@(require_results)
soa_array_get_ptr :: #force_inline proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int) -> #soa^#soa[N]T {
    return &a.data[index]
}

@(require_results)
soa_array_get_safe :: proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int) -> (T, bool) #no_bounds_check {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return a.data[index], true
}

@(require_results)
soa_array_get_ptr_safe :: proc(
    a: ^$A/Soa_Array($N, $T),
    #any_int index: int,
) -> (
    result: #soa^#soa[N]T,
    ok: bool,
) #no_bounds_check {
    if index < 0 || index >= a.len {
        return {}, false
    }
    return &a.data[index], true
}

soa_array_set :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, item: T) {
    a.data[index] = item
}

soa_array_resize :: proc "contextless" (a: ^$A/Soa_Array, #any_int length: int) {
    a.len = clamp(length, 0, builtin.len(a.data))
}


soa_array_push_back :: proc "contextless" (a: ^$A/Soa_Array($N, $T), item: T) -> bool {
    if a.len < N {
        a.data[a.len] = item
        a.len += 1
        return true
    }
    return false
}

soa_array_push_front :: proc "contextless" (a: ^$A/Soa_Array($N, $T), item: T) -> bool {
    if a.len < N {
        a.len += 1
        data := slice(a)
        copy(data[1:], data[:])
        data[0] = item
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

soa_array_pop_front :: proc(a: ^$A/Soa_Array($N, $T), loc := #caller_location) -> T {
    assert(condition = (N > 0 && a.len > 0), loc = loc)
    item := a.data[0]
    s := slice(a)
    copy(s[:], s[1:])
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

soa_array_ordered_remove :: proc "contextless" (
    a: ^$A/Soa_Array($N, $T),
    #any_int index: int,
    loc := #caller_location,
) #no_bounds_check {
    runtime.bounds_check_error_loc(loc, index, a.len)
    if index + 1 < a.len {
        copy(a.data[index:], a.data[index + 1:])
    }
    a.len -= 1
}

soa_array_unordered_remove :: proc "contextless" (
    a: ^$A/Soa_Array($N, $T),
    #any_int index: int,
    loc := #caller_location,
) #no_bounds_check {
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

soa_array_push_back_elems :: proc "contextless" (a: ^$A/Soa_Array($N, $T), items: ..T) {
    n := copy(a.data[a.len:], items[:])
    a.len += n
}

soa_array_inject_at :: proc "contextless" (a: ^$A/Soa_Array($N, $T), item: T, #any_int index: int) -> bool #no_bounds_check {
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

soa_array_append_elem :: soa_array_push_back
soa_array_append_elems :: soa_array_push_back_elems

soa_array_append :: proc {
    soa_array_push_back,
    soa_array_push_back_elems,
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Arr utils
//

arr_len :: proc {
    array_len,
    soa_array_len,
}

arr_cap :: proc {
    array_cap,
    soa_array_cap,
}

arr_slice :: proc {
    array_slice,
    soa_array_slice,
}

arr_in_bounds :: proc {
    array_in_bounds,
    soa_array_in_bounds,
}

arr_get :: proc {
    array_get,
    soa_array_get,
}

arr_get_ptr :: proc {
    array_get_ptr,
    soa_array_get_ptr,
}

arr_get_safe :: proc {
    array_get_safe,
    soa_array_get_safe,
}

arr_get_ptr_safe :: proc {
    array_get_ptr_safe,
    soa_array_get_ptr_safe,
}

arr_set :: proc {
    array_set,
    soa_array_set,
}

arr_resize :: proc {
    array_resize,
    soa_array_resize,
}

arr_push_back :: proc {
    array_push_back,
    soa_array_push_back,
}

arr_push_front :: proc {
    array_push_front,
    soa_array_push_front,
}

arr_pop_back :: proc {
    array_pop_back,
    soa_array_pop_back,
}

arr_pop_front :: proc {
    array_pop_front,
    soa_array_pop_front,
}

arr_pop_back_safe :: proc {
    array_pop_back_safe,
    soa_array_pop_back_safe,
}

arr_pop_front_safe :: proc {
    array_pop_front_safe,
    soa_array_pop_front_safe,
}

arr_ordered_remove :: proc {
    array_ordered_remove,
    soa_array_ordered_remove,
}

arr_unordered_remove :: proc {
    array_unordered_remove,
    soa_array_unordered_remove,
}

arr_clear :: proc {
    array_clear,
    soa_array_clear,
}

arr_push_back_elems :: proc {
    array_push_back_elems,
    soa_array_push_back_elems,
}

arr_inject_at :: proc {
    array_inject_at,
    soa_array_inject_at,
}

arr_append :: arr_push_back
arr_append_elem :: arr_push_back
arr_append_elems :: arr_push_back_elems