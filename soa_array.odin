package sds

import "base:runtime"

Soa_Array :: struct($N: i32, $T: typeid) where N >= 0 {
    data: #soa[N]T `fmt:"len"`,
    len:  i32,
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
soa_array_get :: proc(a: $A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) -> T {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    return a.data[index]
}

@(require_results)
soa_array_get_ptr :: proc(a: ^$A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) -> #soa^#soa[N]T {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    return &a.data[index]
}

soa_array_set :: proc(a: ^$A/Soa_Array($N, $T), #any_int index: int, value: T, loc := #caller_location) {
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

@(require_results)
soa_array_get_safe :: proc "contextless" (a: $A/Soa_Array($N, $T), #any_int index: int) -> (T, bool) #optional_ok {
    if index < 0 || index >= int(a.len) {
        return {}, false
    }
    return a.data[index], true
}

@(require_results)
soa_array_get_ptr_safe :: proc(a: ^$A/Soa_Array($N, $T), #any_int index: int) -> (result: #soa^#soa[N]T, ok: bool) #optional_ok {
    if index < 0 || index >= int(a.len) {
        return {}, false
    }
    return &a.data[index], true
}

soa_array_append :: proc (a: ^$A/Soa_Array($N, $T), item: T, loc := #caller_location) {
    assert(a.len < i32(N), "Reached the array size limit", loc)
    a.data[a.len] = item
    a.len += 1
}

soa_array_append_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T), item: T) -> bool {
    if a.len < N {
        a.data[a.len] = item
        a.len += 1
        return true
    }
    return false
}

soa_array_pop_back :: proc(a: ^$A/Soa_Array($N, $T), loc := #caller_location) -> T {
    assert(a.len > 0, loc = loc)
    item := a.data[a.len - 1]
    a.len -= 1
    return item
}

soa_array_pop_back_safe :: proc "contextless" (a: ^$A/Soa_Array($N, $T)) -> (item: T, ok: bool) #optional_ok {
    if a.len <= 0 {
        return {}, false
    }
    item = a.data[a.len - 1]
    a.len -= 1
    return item, true
}

soa_array_remove :: proc "contextless" (a: ^$A/Soa_Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    n := a.len - 1
    if index != n {
        a.data[index] = a.data[n]
    }
    a.len -= 1
}