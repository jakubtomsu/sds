# 🧊 Static Data Sructures
A small Odin library with useful statically allocated data structures

## Datastructures
- `Array` - Similar to `[dynamic]T`
- `Soa_Array` - Similar to `#soa[dynamic]T`
- `Pool` - A sparse array, which uses [Handles](#handles) to refer to elements. Deleted elements are kept in a free list. All operations are O(1).
- `Indirect_Array` - Uses a Pool to remap Handles into a regular linear array of values. This is essentially a `map[Handle]T`.
- `Queue` - A simple ring-buffer based queue
- `Bit_Array` - Array of booleans stored as single bits. This can be useful in cases where `bit_set` is too small (>128 elements).

All of the datastructures follow ZII - zero is initialization. So you don't need to ever call any `_init/_make` procs.

## Handles
Pool and Indirect_Array use Handles to address items

I recommend reading this blog post by Andre Weissflog to learn more about the benefits of Handles: [Handles are the better pointers](https://floooh.github.io/2018/06/17/handles-vs-pointers.html)


## Contributing
Improvements and bugfixe PRs are welcome. If you want to add a new datastructure I recommend opening an issue first.

## Drop-in include
You can copy&paste this code into your own package to use them directly, instead of using `sds.` prefix.
```odin
import "sds"
array_len :: sds.array_len
array_cap :: sds.array_cap
array_slice :: sds.array_slice
array_in_bounds :: sds.array_in_bounds
array_get :: sds.array_get
array_get_ptr :: sds.array_get_ptr
array_get_safe :: sds.array_get_safe
array_get_ptr_safe :: sds.array_get_ptr_safe
array_set :: sds.array_set
array_resize :: sds.array_resize
array_push_back :: sds.array_push_back
array_push_front :: sds.array_push_front
array_pop_back :: sds.array_pop_back
array_pop_front :: sds.array_pop_front
array_pop_back_safe :: sds.array_pop_back_safe
array_pop_front_safe :: sds.array_pop_front_safe
array_ordered_remove :: sds.array_ordered_remove
array_unordered_remove :: sds.array_unordered_remove
array_clear :: sds.array_clear
array_push_back_elems :: sds.array_push_back_elems
array_inject_at :: sds.array_inject_at

soa_array_len :: sds.soa_array_len
soa_array_cap :: sds.soa_array_cap
soa_array_slice :: sds.soa_array_slice
soa_array_in_bounds :: sds.soa_array_in_bounds
soa_array_get :: sds.soa_array_get
soa_array_get_ptr :: sds.soa_array_get_ptr
soa_array_get_safe :: sds.soa_array_get_safe
soa_array_get_ptr_safe :: sds.soa_array_get_ptr_safe
soa_array_set :: sds.soa_array_set
soa_array_resize :: sds.soa_array_resize
soa_array_push_back :: sds.soa_array_push_back
soa_array_push_front :: sds.soa_array_push_front
soa_array_pop_back :: sds.soa_array_pop_back
soa_array_pop_front :: sds.soa_array_pop_front
soa_array_pop_back_safe :: sds.soa_array_pop_back_safe
soa_array_pop_front_safe :: sds.soa_array_pop_front_safe
soa_array_ordered_remove :: sds.soa_array_ordered_remove
soa_array_unordered_remove :: sds.soa_array_unordered_remove
soa_array_clear :: sds.soa_array_clear
soa_array_push_back_elems :: sds.soa_array_push_back_elems
soa_array_inject_at :: sds.soa_array_inject_at

arr_len :: sds.arr_len
arr_cap :: sds.arr_cap
arr_slice :: sds.arr_slice
arr_in_bounds :: sds.arr_in_bounds
arr_get :: sds.arr_get
arr_get_ptr :: sds.arr_get_ptr
arr_get_safe :: sds.arr_get_safe
arr_get_ptr_safe :: sds.arr_get_ptr_safe
arr_set :: sds.arr_set
arr_resize :: sds.arr_resize
arr_push_back :: sds.arr_push_back
arr_push_front :: sds.arr_push_front
arr_pop_back :: sds.arr_pop_back
arr_pop_front :: sds.arr_pop_front
arr_pop_back_safe :: sds.arr_pop_back_safe
arr_pop_front_safe :: sds.arr_pop_front_safe
arr_ordered_remove :: sds.arr_ordered_remove
arr_unordered_remove :: sds.arr_unordered_remove
arr_clear :: sds.arr_clear
arr_push_back_elems :: sds.arr_push_back_elems
arr_inject_at :: sds.arr_inject_at
arr_append :: sds.arr_append
arr_append_elem :: sds.arr_append_elem
arr_append_elems :: sds.arr_append_elems



bit_array_get :: sds.bit_array_get
bit_array_set :: sds.bit_array_set
bit_array_unset :: sds.bit_array_unset
bit_array_assign :: sds.bit_array_assign
bit_array_get_safe :: sds.bit_array_get_safe
bit_array_set_safe :: sds.bit_array_set_safe
bit_array_unset_safe :: sds.bit_array_unset_safe
bit_array_assign_safe :: sds.bit_array_assign_safe
```
