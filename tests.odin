//+private file
package static_data_structures

import "core:fmt"
import "core:testing"

println :: fmt.println

@(test)
test_pool_a :: proc(t: ^testing.T) {
        p: Pool(1024, u32, u8, f32)

        h0, h0_ok := pool_append(&p, 123)
        assert(h0_ok)
        assert(pool_is_handle_used(p, h0))
        assert(pool_get(p, h0) == 123)
        assert(handle_index(h0) == 1)
        assert(handle_gen(h0) == 0)
        assert(p.max_index == 1)
        pool_set(&p, h0, 66)
        assert(pool_get(p, h0) == 66)

        h1, h1_ok := pool_append(&p, 345)
        assert(h1_ok)
        assert(pool_get(p, h1) == 345)

        assert((pool_remove(&p, h0) or_else 0) == 66)

        assert(!pool_is_handle_used(p, h0))
        assert(pool_get(p, h0) == 0)

        h2, h2_ok := pool_append(&p, 99)
        assert(h2_ok)
        assert(handle_index(h2) == 1)
        assert(handle_gen(h2) == 1)

        h3, h3_ok := pool_append(&p, 70707)
        assert(h3_ok)
}


@(test)
test_pool_b :: proc(t: ^testing.T) {
        p: Pool(1024, u16, struct {}, f64)

        h0, h0_ok := pool_append(&p, 123)
        assert(h0_ok)
        assert(pool_is_handle_used(p, h0))
        assert(pool_get(p, h0) == 123)
        assert(handle_index(h0) == 1)
        assert(handle_gen(h0) == {})
        assert(p.max_index == 1)
        pool_set(&p, h0, 66)
        assert(pool_get(p, h0) == 66)

        h1, h1_ok := pool_append(&p, 345)
        assert(h1_ok)
        assert(pool_get(p, h1) == 345)

        assert((pool_remove(&p, h0) or_else 0) == 66)

        // Note: without the generation we can't know if it still exists, so `pool_exists` acts only as a bounds check.
        // Don't try to access the value though!
        // assert(pool_is_handle_used(p, h0))

        h2, h2_ok := pool_append(&p, 99)
        assert(h2_ok)
        assert(handle_index(h2) == 1)

        h3, h3_ok := pool_append(&p, 70707)
        assert(h3_ok)
        _ = h3
}

@(test)
test_indirect_array :: proc(t: ^testing.T) {
    m: Indirect_Array(1024, u32, u8, int)

    h0 := indirect_array_append(&m, 123) or_else panic("")
    /*assert((indirect_array_get(m, h0) or_else panic("")) == 123)
    assert((indirect_array_get_ptr(&m, h0) or_else panic(""))^ == 123)
    if _, ok := indirect_array_set(&m, h0, 66); !ok do panic("")

    h1 := indirect_array_append(&m, 234) or_else panic("")
    assert((indirect_array_get(m, h1) or_else panic("")) == 234)
    assert((indirect_array_get_ptr(&m, h1) or_else panic(""))^ == 234)

    for item in m.items {
        println(item.value)
    }

    assert((indirect_array_remove(&m, h0) or_else panic("")) == 66)*/
}