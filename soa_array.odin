package sds

import "base:runtime"

/*
SOA Array - (almost) fully compatible variant of Array

Note: in this particular case it's not possible to store an invalid value like in all other datastructures,
due to the way SOA pointers work. So a pointer to data[0] is returned instead and get_ptr_safe is _not_ #optional_ok.
*/
Soa_Array :: struct($Num: i32, $Val: typeid) where Num >= 0 {
    data:          #soa[Num]Val,
    len:           i32,
}

@(require_results)
soa_array_has_index :: proc "contextless" (a: $A/Soa_Array, #any_int index: int) -> bool {
    return index >= 0 && index < int(a.len)
}

@(require_results)
soa_array_slice :: #force_inline proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> #soa[]T {
    return a.data[:a.len]
}

@(require_results)
soa_array_get :: proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) -> T {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    return a.data[index]
}

@(require_results)
soa_array_get_safe :: proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int) -> (T, bool) #optional_ok {
    if index < 0 || index >= int(a.len) {
        return {}, false
    }
    return a.data[index], true
}

@(require_results)
soa_array_get_ptr :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) -> #soa^#soa[N]T {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    return &a.data[index]
}

@(require_results)
soa_array_get_ptr_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int) -> (result: #soa^#soa[N]T, ok: bool) {
    if index < 0 || index >= int(a.len) {
        // NOTE: not possible to return invalid value, that's why it's not #optional_ok
        return &a.data[0], false
    }
    return &a.data[index], true
}

soa_array_set :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, value: T, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    a.data[index] = value
}

soa_array_set_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, value: T) -> bool {
    if index < 0 || index >= int(a.len) {
        return false
    }
    a.data[index] = value
    return true
}

soa_array_push :: proc (a: ^$A/Soa_Array($N, $T), elem: T, loc := #caller_location) -> (index: int) {
    assert_contextless(a.len < i32(N), "Reached the array size limit", loc)
    index = int(a.len)
    a.data[index] = elem
    a.len += 1
    return index
}

soa_array_push_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T), elem: T) -> (index: int, ok: bool) #optional_ok {
    index = soa_array_push_empty(a) or_return
    a.data[index] = elem
    return index, true
}

@(require_results)
soa_array_push_empty :: proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> (index: int, ok: bool) #optional_ok {
    if a.len >= N {
        return 0, false
    }
    index = int(a.len)
    a.len += 1
    return index, true
}

soa_array_pop_back :: proc "contextless" (a: ^$A/Soa_Array($N, $T), loc := #caller_location) -> T {
    assert_contextless(a.len > 0, "SOA Array is empty", loc)
    elem := a.data[a.len - 1]
    a.len -= 1
    return elem
}

soa_array_pop_back_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> (elem: T, ok: bool) #optional_ok {
    if a.len <= 0 {
        return {}, false
    }
    elem = a.data[a.len - 1]
    a.len -= 1
    return elem, true
}

soa_array_remove :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    n := a.len - 1
    if index != int(n) {
        a.data[index] = a.data[n]
    }
    a.len -= 1
}