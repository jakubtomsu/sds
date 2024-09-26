# 💾 Static Data Sructures
A small Odin library with useful fixed-size data structures. This means all of the data uses just static arrays (`[N]T`), no dynamic allocations whatsoever.

> ![WARNING]
> I just got started with some changes for the public release of this lib so who knows if things work as they should.

## Datastructures
- `Array` - Similar to `[dynamic]T`
- `Soa_Array` - Similar to `#soa[dynamic]T`
- `Pool` - A sparse array, which uses [Handles](#handles) to refer to elements. Deleted elements are kept in a free list. All operations are O(1). Usage is similar to `map[Handle]T`. Overhead is one index and one generation counter per item.
- `Indirect_Array` - Uses a Pool to remap Handles into a regular linear array of values. All operations are O(1). Usage is similar to `map[Handle]T`. Overhead is two indexes and one generation counter per item.
- `Queue` - A simple ring-buffer based queue
- `Bit_Array` - Array of booleans stored as single bits. This can be useful in cases where `bit_set` is too small (>128 elements).

All of the datastructures follow ZII - zero is initialization. So you don't need to ever call any `_init/_make` procs.

## Handles
Pool and Indirect_Array use Handles to address items. A handle is sort of like a unique ID, however it can optionally also have a "generation index". This is useful because IDs can be reused, but the generation index check makes sure you are accessing the item you _think_ you are. This prevents "use-after-removed" kinds of bugs.

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

## Contributing
Improvements and bugfixe PRs are welcome. If you want to add a new datastructure I recommend opening an issue first.
