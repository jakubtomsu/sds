# 🧊 Static Data Sructures
A small Odin library with useful statically allocated data structures

## Datastructures
- `Array` - Similar to `[dynamic]T`
- `Soa_Array` - Similar to `#soa[dynamic]T`
- `Pool` - A sparse array, which uses [Handles](#handles) to refer to elements. Deleted elements are kept in a free list. All operations are O(1). Usage is similar to `map[Handle]T`.
- `Indirect_Array` - Uses a Pool to remap Handles into a regular linear array of values. All operations are O(1). Usage is similar to `map[Handle]T`.
- `Queue` - A simple ring-buffer based queue
- `Bit_Array` - Array of booleans stored as single bits. This can be useful in cases where `bit_set` is too small (>128 elements).

All of the datastructures follow ZII - zero is initialization. So you don't need to ever call any `_init/_make` procs.

## Handles
Pool and Indirect_Array use Handles to address items. A handle is sort of like a unique ID, however it can optionally also have a "generation index". This is useful because IDs can be reused, but the generation index check makes sure you are accessing the item you _think_ you are. This prevents "use-after-removed" kinds of bugs.

I recommend reading this blog post by Andre Weissflog to learn more about the benefits of Handles: [Handles are the better pointers](https://floooh.github.io/2018/06/17/handles-vs-pointers.html)


## Why fixed size?
You might be thinking, why should I use fixed size datastructures, instead of letting them allocate memory dynamically?

## Contributing
Improvements and bugfixe PRs are welcome. If you want to add a new datastructure I recommend opening an issue first.