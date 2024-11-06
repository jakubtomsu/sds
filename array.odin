package sds

import "base:builtin"
import "base:runtime"

/*
Static array with dynamic length

Based on core:container/small_array.
Usage is similar to `[dynamic]T`
*/
Array :: struct($Num: i32, $Val: typeid) where Num >= 0 {
    data:          [Num]Val,
    len:           i32,
    invalid_value: Val,
}

@(require_results)
array_has_index :: #force_inline proc "contextless" (a: $A/Array, #any_int index: int) -> bool {
    return index >= 0 && index < int(a.len)
}

@(require_results)
array_slice :: #force_inline proc "contextless" (a: ^$A/Array($N, $T)) -> []T {
    return a.data[:a.len]
}

@(require_results)
array_get :: #force_inline proc "contextless" (a: $A/Array($N, $T), #any_int index: int, loc := #caller_location) -> T {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    return a.data[index]
}

@(require_results)
array_get_safe :: proc "contextless" (a: $A/Array($N, $T), #any_int index: int) -> (T, bool) #optional_ok {
    if index < 0 || index >= int(a.len) {
        return {}, false
    }
    return a.data[index], true
}

@(require_results)
array_get_ptr :: #force_inline proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, loc := #caller_location) -> ^T {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    return &a.data[index]
}

@(require_results)
array_get_ptr_safe :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int) -> (^T, bool) #optional_ok {
    if index < 0 || index >= int(a.len) {
        return &a.invalid_value, false
    }
    return &a.data[index], true
}

array_set :: #force_inline proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, value: T, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    a.data[index] = value
}

array_set_safe :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, value: T) -> bool {
    if index < 0 || index >= int(a.len) {
        return false
    }
    a.data[index] = value
    return true
}

// Returns index of the pushed value
array_push :: proc "contextless" (a: ^$A/Array($N, $T), item: T, loc := #caller_location) -> int {
    assert_contextless(a.len < i32(N), "Reached the array size limit", loc)
    index := a.len
    a.data[index] = item
    a.len += 1
    return int(index)
}

array_push_safe :: proc "contextless" (a: ^$A/Array($N, $T), item: T) -> (index: int, ok: bool) #optional_ok {
    index = array_push_empty(a) or_return
    a.data[index] = item
    return index, true
}

// Warning: doesn't clear previous value!
@(require_results)
array_push_empty :: proc "contextless" (a: ^$A/Array($N, $T)) -> (index: int, ok: bool) #optional_ok {
    if a.len >= N {
        return 0, false
    }
    index = int(a.len)
    a.len += 1
    return index, true
}

array_push_elems :: proc "contextless" (a: ^$A/Array($N, $T), elems: ..T, loc := #caller_location) {
    n := copy(a.data[a.len:], elems[:])
    a.len += i32(n)
    assert_contextless(n == len(elems), "Not enough space in the array", loc)
}

array_push_elems_safe :: proc "contextless" (a: ^$A/Array($N, $T), elems: ..T) -> bool {
    n := copy(a.data[a.len:], elems[:])
    a.len += n
    return n == len(elems)
}


@(require_results)
array_pop_back :: proc "contextless" (a: ^$A/Array($N, $T), loc := #caller_location) -> T {
    assert_contextless(a.len > 0, "Array is empty", loc)
    item := a.data[a.len - 1]
    a.len -= 1
    return item
}

@(require_results)
array_pop_back_safe :: proc "contextless" (a: ^$A/Array($N, $T)) -> (item: T, ok: bool) #optional_ok {
    if a.len <= 0 {
        return {}, false
    }
    item = a.data[a.len - 1]
    a.len -= 1
    return item, true
}

array_remove :: proc "contextless" (a: ^$A/Array($N, $T), #any_int index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    n := a.len - 1
    if index != int(n) {
        a.data[index] = a.data[n]
    }
    a.len -= 1
}

array_from_slice :: proc "contextless" (a: ^$A/Array($N, $T), data: []T) -> bool {
    a.len = cast(i32)copy(a.data[:], data)
    return int(a.len) == len(data)
}