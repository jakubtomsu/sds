package sds

import "base:runtime"

/*
Queue (Ring Buffer / Circular Buffer)

Based on 'core:container/queue'.
*/
Queue :: struct($Num: u64, $Val: typeid) where Num > 0 {
    offset:         u64,
    len:            u64,
    data:           [Num]Val,
    invalid_value:  Val,
}

@(require_results)
queue_get :: proc "contextless" (q: $T/Queue($N, $V), #any_int index: int) -> V {
    return q.data[(int(q.offset) + index) % int(N)]
}

@(require_results)
queue_get_safe :: proc "contextless" (q: $T/Queue($N, $V), #any_int index: int, loc := #caller_location) -> (V, bool) #optional_ok {
    if index < 0 || index >= int(N) {
        return {}, false
    }
    return q.data[(int(q.offset) + index) % int(N)], true
}

@(require_results)
queue_get_ptr :: proc "contextless" (q: ^$T/Queue($N, $V), #any_int index: int) -> ^V {
    return &q.data[(int(q.offset) + index) % int(N)]
}

@(require_results)
queue_get_ptr_safe :: proc "contextless" (q: ^$T/Queue($N, $V), #any_int index: int, loc := #caller_location) -> (^V, bool) #optional_ok {
    if index < 0 || index >= int(N) {
        return &q.invalid_value, false
    }
    return &q.data[(int(q.offset) + index) % int(N)], true
}

queue_set :: proc "contextless" (q: ^$T/Queue($N, $V), #any_int index: int, val: V, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, index, int(a.len))
    q.data[(int(q.offset) + index) % int(N)] = val
}

queue_set_safe :: proc "contextless" (q: ^$T/Queue($N, $V), #any_int index: int, val: V, loc := #caller_location) -> bool {
    if index < 0 || index >= N {
        return false
    }
    q.data[(int(q.offset) + index) % int(N)] = val
    return true
}

@(require_results)
queue_peek_front :: proc "contextless" (q: ^$T/Queue($N, $V), loc := #caller_location) -> ^V {
    assert_contextless(q.len > 0, "Queue is empty", loc)
    return &q.data[q.offset % N]
}

@(require_results)
queue_peek_front_safe :: proc "contextless" (q: ^$T/Queue($N, $V), loc := #caller_location) -> (^V, bool) {
    if q.len <= 0 {
        return &q.invalid_value, false
    }
    return &q.data[q.offset % N]
}

@(require_results)
queue_peek_back :: proc "contextless" (q: ^$T/Queue($N, $V), loc := #caller_location) -> ^V {
    assert_contextless(q.len > 0, "Queue is empty", loc)
    return &q.data[(q.offset + q.len - 1) % N]
}

@(require_results)
queue_peek_back_safe :: proc "contextless" (q: ^$T/Queue($N, $V)) -> (^V, bool) #optional_ok {
    if q.len <= 0 {
        return &q.invalid_value, false
    }
    return &q.data[(q.offset + q.len - 1) % N], true
}

// Push an element to the back of the queue
queue_push_back :: proc "contextless" (q: ^$T/Queue($N, $V), value: V) -> bool {
    if q.len >= N {
        return false
    }
    q.data[(q.offset + q.len) % N] = value
    q.len += 1
    return true
}

// Push multiple elements to the front of the queue
queue_push_back_elems :: proc "contextless" (q: ^$T/Queue($N, $V), elems: ..V) -> bool {
    n := u64(len(elems))
    if q.len + n > N {
        return false
    }
    sz := u64(N)
    insert_from := (q.offset + q.len) % sz
    insert_to := n
    if insert_from + insert_to > sz {
        insert_to = sz - insert_from
    }
    copy(q.data[insert_from:], elems[:insert_to])
    copy(q.data[:insert_from], elems[insert_to:])
    q.len += n
    return true
}

// Push an element to the front of the queue
queue_push_front :: proc "contextless" (q: ^$T/Queue($N, $V), elem: V) -> bool {
    if q.len >= N {
        return false
    }
    q.offset = (q.offset - 1 + N) % N
    q.len += 1
    q.data[q.offset] = elem
    return true
}


// Pop an element from the back of the queue
@(require_results)
queue_pop_back :: proc "contextless" (q: ^$T/Queue($N, $V), loc := #caller_location) -> V {
    assert_contextless(q.len > 0, "Queue is empty", loc)
    q.len -= 1
    return q.data[(q.offset + q.len) % N]
}

// Safely pop an element from the back of the queue
@(require_results)
queue_pop_back_safe :: proc "contextless" (q: ^$T/Queue($N, $V)) -> (V, bool) #optional_ok {
    if q.len <= 0 {
        return {}, false
    }
    q.len -= 1
    return q.data[int(q.offset + q.len) % int(N)], true
}

// Pop an element from the front of the queue
@(require_results)
queue_pop_front :: proc "contextless" (q: ^$T/Queue($N, $V), loc := #caller_location) -> (result: V) {
    assert_contextless(q.len > 0, "Queue is empty", loc)
    result = q.data[q.offset]
    q.offset = (q.offset + 1) % N
    q.len -= 1
    return result
}

// Safely pop an element from the front of the queues
@(require_results)
queue_pop_front_safe :: proc "contextless" (q: ^$T/Queue($N, $V)) -> (result: V, ok: bool) #optional_ok {
    if q.len <= 0 {
        return {}, false
    }
    result = q.data[q.offset]
    q.offset = (q.offset + 1) % N
    q.len -= 1
    return result, true
}