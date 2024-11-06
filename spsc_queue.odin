package sds

import "base:intrinsics"


/*
SPSC - Single-Producer Single-Consumer Lock-Free Queue

This is a ring buffer which can be safely operated on by two threads:
- one "producer" which keeps pushing values
- and one "consumer" which keeps popping them

(in theory it's safe for both threads to push and pop at once, but it's probably not a good architecture)

There is no internal locking, only two atomic operations per push/pop.

Push can fail if the queue is full, there are a few ways you can deal with that:
1. ignore it and throw away the value
2. run push in a hot loop until it succeeds
3. retry push after some time if it fails, doing additional work in-between

In case you want to have more than 1 producers or consumers, you can use multiple SPSC queues instead of
a much more complex MPMC/SPMC/MPSC queues. You can create one SPSC queue for every producer/consumer,
and then the consumer/producer is going to iterate all those queues one by one, instead of reading from just one global queue.

 ┌─────┐  ┌─────┐  ┌─────┐     ┌─────┐  ┌─────┐  ┌─────┐
 │prod1│  │prod2│  │prod3│     │cons1│  │cons2│  │cons3│
 └──┬──┘  └──┬──┘  └──┬──┘     └──▲──┘  └──▲──┘  └──▲──┘
 ┌──▼──┐  ┌──▼──┐  ┌──▼──┐     ┌──┼──┐  ┌──┼──┐  ┌──┼──┐
 │spsc1│  │spsc2│  │spsc3│     │spsc1│  │spsc2│  │spsc3│
 └──┬──┘  └──┬──┘  └──┬──┘     └──▲──┘  └──▲──┘  └──▲──┘
    │   ┌────▼───┐    │           │   ┌────┼───┐    │
    └───►consumer◄────┘           └───┼producer┼────┘
        └────────┘                    └────────┘


This queue also doesn't support many of the same procedures as regular Queue, because the practical use-case
is very different. You should think about this as a "pipe" between two parallel systems, similar to what hardware does.

You should consider batching your pushes and pops and call push_elems/pop_elems with more than one item at once.
However it depends on your workload, it's a tradeoff between latency between producer and consumer,
and the overhead spent on synchronization.

The head/tail values are each on a separate cache-line to avoid false sharing.
I'm not sure if it's necessary to separate *all* of them, maybe tails could be shared
since they are both accessed by both threads at roughly the same time.
However the overhead is just 4 cache lines, which is nothing for a big queue.

Resources:
https://github.com/freebsd/freebsd-src/blob/main/sys/sys/buf_ring.h
https://book-of-gehn.github.io/articles/2020/03/22/Lock-Free-Queue-Part-I.html
*/
SPSC :: struct($Num: u64, $Val: typeid) {
    using _: struct #align(64) { producer_head:  u64, },
    using _: struct #align(64) { producer_tail:  u64, },
    using _: struct #align(64) { consumer_head:  u64, },
    using _: struct #align(64) { consumer_tail:  u64, },
    data: [Num]Val,
}

spsc_push_elems :: proc "contextless" (q: ^$T/SPSC($N, $V), vals: ..V) -> int {
    vals := vals
    old_producer_head := q.producer_head
    consumer_tail := intrinsics.atomic_load_explicit(&q.consumer_tail, .Acquire)
    free_entries := (N + consumer_tail - old_producer_head)
    vals = vals[:min(len(vals), int(free_entries))]
    if len(vals) <= 0 {
        return 0
    }
    new_producer_head := old_producer_head + u64(len(vals))
    q.producer_head = new_producer_head
    for val, i in vals {
        q.data[(old_producer_head + u64(i)) % N] = val
    }
    intrinsics.atomic_store_explicit(&q.producer_tail, new_producer_head, .Release)
    return len(vals)
}

spsc_pop_elems :: proc "contextless" (q: ^$T/SPSC($N, $V), buf: []V) -> []V {
    old_consumer_head := q.consumer_head
    producer_tail := intrinsics.atomic_load_explicit(&q.producer_tail, .Acquire)
    ready_entries := producer_tail - old_consumer_head
    result := buf[:min(len(buf), int(ready_entries))]
    if len(result) <= 0 {
        return {}
    }
    new_consumer_head := old_consumer_head + u64(len(result))
    q.consumer_head = new_consumer_head
    for i in 0..<len(result) {
        result[i] = q.data[(old_consumer_head + u64(i)) % N]
    }
    intrinsics.atomic_store_explicit(&q.consumer_tail, new_consumer_head, .Release)
    return result
}

spsc_push :: proc "contextless" (q: ^$T/SPSC($N, $V), val: V) -> bool {
    return 1 == #force_inline spsc_push_elems(q, val)
}

spsc_pop :: proc "contextless" (q: ^$T/SPSC($N, $V)) -> (result: V, ok: bool) {
    res := #force_inline spsc_pop_elems(q, (cast([^]V)&result)[:1])
    return result, len(res) == 1
}