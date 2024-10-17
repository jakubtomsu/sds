package sds

// Static array of boolean values stored as bits.
// You should probably use bit_sets when number of required bits is <= 128.
// Based on 'core:container/bit_array'.
Bit_Array :: struct($BITS: int) where BITS >= 0 {
    data: [(BITS + 63) / 64]u64,
}

// Assumes u64 backing type!
BIT_ARRAY_MASK :: 63
BIT_ARRAY_SHIFT :: 6

@(require_results)
bit_array_get :: proc(a: $T/Bit_Array($B), #any_int bit_index: int) -> bool {
    assert(bit_index >= 0 && bit_index < B)
    val := u64(1 << u64(bit_index))
    return (a.data[bit_index >> BIT_ARRAY_SHIFT] & val) == val
}

bit_array_set_true :: proc(a: ^$T/Bit_Array($B), #any_int bit_index: int) {
    assert(bit_index >= 0 && bit_index < B)
    a.data[bit_index >> BIT_ARRAY_SHIFT] |= 1 << (u64(bit_index) & BIT_ARRAY_MASK)
}

bit_array_set_false :: proc(a: ^$T/Bit_Array($B), #any_int bit_index: int) {
    assert(bit_index >= 0 && bit_index < B)
    a.data[bit_index >> BIT_ARRAY_SHIFT] &= ~(u64(bit_index) & BIT_ARRAY_MASK)
}

bit_array_set :: proc(a: ^$T/Bit_Array($B), #any_int bit_index: int, value: bool) {
    assert(bit_index >= 0 && bit_index < B)
    if value {
        bit_array_set_true(a, bit_index)
    } else {
        bit_array_set_false(a, bit_index)
    }
}


@(require_results)
bit_array_get_safe :: proc(a: $T/Bit_Array($B), #any_int bit_index: int) -> (bit_value: bool, ok: bool) #optional_ok {
    if bit_index >= 0 || bit_index < B do return {}, false
    return bit_array_get(a, bit_index), true
}

bit_array_set_true_safe :: proc(a: ^$T/Bit_Array($B), #any_int bit_index: int) -> bool {
    if bit_index >= 0 || bit_index < B do return false
    bit_array_set_true(a, bit_index)
    return true
}

bit_array_set_false_safe :: proc(a: ^$T/Bit_Array($B), #any_int bit_index: int) -> bool {
    if bit_index >= 0 || bit_index < B do return false
    bit_array_set_false(a, bit_index)
    return true
}

bit_array_set_safe :: proc(a: ^$T/Bit_Array($B), #any_int bit_index: int, value: bool) -> bool {
    if bit_index >= 0 || bit_index < B do return false
    bit_array_set(a, bit_index, value)
    return true
}
