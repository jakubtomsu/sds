# 💾 Static Data Sructures
A small Odin library with useful fixed-size data structures. This means all of the data is internally stored just as static arrays (`[N]T`), no dynamic allocations whatsoever.

[Why fixed size?](#why-fixed-size)

## Datastructures
Name | Similar To | Info
---- | ---------- | ----
Array | `[dynamic]T` or `core:container/small_array` | Regular static array with dynamic number of elements (`[N]T` + `int` for length)
Soa_Array | `#soa[dynamic]T` | Variant of `Array` with `#soa` backing buffer
Pool | none |  A sparse array, which uses [Handles](#handles) to refer to elements. Deleted elements are kept in a free list. All operations are O(1). Overhead is one index and one generation counter per item.
Queue | core:container/queue | A simple ring buffer queue.
Bit_Array | bit_set for >128 element support | Array of booleans stored as single bits. This can be useful in cases where `bit_set` is too small (>128 elements).
SPSC | Queue | Single-producer single-consumer lock-free ring buffer queue for multithreaded systems.

> Note: There used to be an Indirect_Array which remaps sparse handles to linear array using a pool. It was removed in commit [d381140](https://github.com/jakubtomsu/sds/commit/d3811401c59c02e3cf960c95229a85557e398276) because a pool pretty much covers all the use cases in practice.

All of the datastructures follow ZII - zero is initialization. So you don't need to ever call any `_init/_make` procs. There is also always a "dummy" invalid value which is returned in case `*_get_ptr` procs fail.

> [!NOTE]
> Some very basic procedures like `len`, `cap`, `resize` etc are intentionally missing for simplicity.
> Don't be afraid to just directly read the member values like `len` from the structs.

### Pool Example
The Pool datastructure is probably the most useful to gamedevs, so here is a short example of practical usage:
```odin
import "sds"

// Distinct type for safety!
Enemy_Handle :: distinct sds.Handle(u16, u16)

Enemy :: struct {
    pos:    [2]f32,
    health: f32,
}

Game :: struct {
    enemies: sds.Pool(1024, Enemy, Enemy_Handle),
}

game_tick :: proc(game: ^Game, delta: f32) {
    for i in 1..=game.enemies.max_index {
        enemy, handle := sds.pool_index_get_ptr_safe(&game.enemies, i) or_continue
        // ...
        if enemy.health < 0 {
            sds.remove(&game.enemies, handle)
        }
    }
}

game_draw :: proc(game: Game) {
    for i in 1..=game.enemies.max_index {
        enemy, handle := sds.pool_index_get_safe(game.enemies, i) or_continue
        // ...
    }
}
```

## Handles
Pool uses Handles to address items. A handle is sort of like a unique ID, however it can optionally also have a "generation index". This is useful because IDs can be reused, but the generation index check makes sure you are accessing the item you _think_ you are. This prevents "use-after-removed" kinds of bugs.

I recommend reading this blog post by Andre Weissflog to learn more about the benefits of Handles: [Handles are the better pointers](https://floooh.github.io/2018/06/17/handles-vs-pointers.html)


## Why fixed size?
You might be thinking, why should I use fixed size datastructures, instead of letting them allocate memory dynamically? Odin has a great allocator system, but there are still reasons I find fixed-size nicer in 99% of cases.

- it's good to be explicit about the limits because the code operating on the data has limits anyway, whether you acknowledge it or not.
- prioritizes worst-case performance over the average case which is arguably much more important in general
- it's very obvious when you're doing something that would use a LOT of memory, so you come up with a different way to manage the data. With dynamic memory it's much easier to use huge amounts of memory without realizing it.
- no need to make and delete datastructures (if you wanted [dynamic] arrays with specific capacity for example)
- it's trivial to do a "deep copy" of the entire datastructure. If you use only fixed-size datastructures and have a big `Global_Data` struct with all the program state, you can trivially serialize it, or pass it between modules when hotreloading.
- pointers never get invalidated. That said, you still probably want to use indexes or handles
- it's just a bit simpler than the alternatives

There are definitely cases when fixed-size is not a very good fit, but in software like games it works _really_ well in my experience.

I also recommend reading the [TigerBeetle database coding style](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md), which also heavily relies on static memory allocation.

## Contributing
Improvements and bugfix PRs are welcome. If you want to add a new datastructure or a big feature like that I recommend opening an issue first.
