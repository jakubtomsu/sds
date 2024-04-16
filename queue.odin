package static_data_structures

// Queue / Ring Buffer / Circular Buffer
Queue :: struct($Num: int, $Val: typeid) {
    offset: uint,
    len:    uint,
    values: [Num]Val,
}

queue_clear :: proc(q: ^$T/Queue($N, $V)) {
    q.head = 0
    q.tail = 0
}

@(require_results)
queue_len :: proc "contextless" (q: $T/Queue($N, $V)) -> int {
    return int(q.len)
}

queue_space :: proc "contextless" (q: $T/Queue($N, $V)) -> int {
    return N - int(q.len)
}

@(require_results)
queue_get :: proc(q: ^$T/Queue($N, $V), #any_int index: int) -> V {
    return q.data[(q.offset + index) % N]
}

@(require_results)
queue_get_safe :: proc(q: ^$T/Queue($N, $V), #any_int index: int, loc := #caller_location) -> (V, bool) #optional_ok {
    if index < 0 || index >= N {
        return {}, false
    }
    return q.data[(q.offset + index) % N], true
}

@(require_results)
queue_get_ptr :: proc(q: ^$T/Queue($N, $V), #any_int index: int) -> ^V {
    return &q.data[(q.offset + index) % N]
}

@(require_results)
queue_get_ptr_safe :: proc(q: ^$T/Queue($N, $V), #any_int index: int, loc := #caller_location) -> ^V {
    if index < 0 || index >= N {
        return {}, false
    }
    return &q.data[(q.offset + index) % N], true
}

queue_set :: proc(q: ^$T/Queue($N, $V), #any_int index: int, val: V) {
    q.data[(q.offset + index) % N] = val
}

queue_set_safe :: proc(q: ^$T/Queue($N, $V), #any_int index: int, val: V, loc := #caller_location) -> bool {
    if index < 0 || index >= N {
        return false
    }
    q.data[(q.offset + index) % N] = val
    return true
}

@(require_results)
queue_peek_front :: proc(q: ^$T/Queue($N, $V)) -> ^V {
    return &q.data[q.offset % N]
}

@(require_results)
queue_peek_back :: proc(q: ^$T/Queue($N, $V)) -> ^V {
    return &q.data[(q.offset + q.len - 1) % N]
}

// Push an element to the back of the queue
queue_push_back :: proc(q: ^$T/Queue($N, $V), value: V) -> bool {
    if q.len >= N {
        return false
    }
    q.data[(q.offset + uint(q.len)) % N] = elem
    q.len += 1
    return true
}

// Push multiple elements to the front of the queue
queue_push_back_elems :: proc(q: ^$T/Queue($N, $V), values: ..V, loc := #caller_location) -> bool {
    n := uint(len(values))
    if q.len + n > N {
        return false
    }
    sz := uint(N)
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
queue_push_front :: proc(q: ^$T/Queue($N, $V), value: V, loc := #caller_location) -> bool {
    if q.len >= N {
        return false
    }
    q.offset = uint(q.offset - 1 + N) % N
    q.len += 1
    q.data[q.offset] = elem
    return true
}


// Pop an element from the back of the queue
@(require_results)
queue_pop_back_fast :: proc "contextless" (q: ^$T/Queue($N, $V)) -> V {
    q.len -= 1
    return q.data[(q.offset + q.len) % N]
}

// Safely pop an element from the back of the queue
@(require_results)
queue_pop_back :: proc(q: ^$T/Queue($N, $V)) -> (T, bool) #optional_ok {
    if q.len <= 0 {
        return {}, false
    }
    return queue_pop_back_fast(q), true
}

// Pop an element from the front of the queue
@(require_results)
queue_pop_front_fast :: proc "contextless" (q: ^$T/Queue($N, $V)) -> (result: V) {
    result = q.data[q.offset]
    q.offset = (q.offset + 1) % N
    q.len -= 1
    return result
}

// Safely pop an element from the front of the queues
@(require_results)
queue_pop_front :: proc(q: ^$T/Queue($N, $V)) -> (result: V, ok: bool) #optional_ok {
    if q.len <= 0 {
        return {}, false
    }
    return queue_pop_front_fast(q), true
}
