package static_data_structures

import "base:intrinsics"
import "base:runtime"

// Invalid handle is zero ({})
// GEN could be assigned to struct{}
// odinfmt: disable
Handle :: struct($INDEX, $GEN: typeid) #raw_union
    where intrinsics.type_is_integer(INDEX) &&
    size_of(INDEX) > size_of(GEN) &&
    (size_of(GEN) == 0 || intrinsics.type_is_unsigned(GEN))
{
    gen:   GEN,
    value: INDEX,
}
// odinfmt: enable

@(require_results)
handle_index :: #force_inline proc "contextless" (handle: Handle($I, $G)) -> I {
    when size_of(G) > 0 {
        return handle.value >> (size_of(G) * 8)
    } else {
        return handle.value
    }
}

@(require_results)
handle_gen :: #force_inline proc "contextless" (handle: Handle($T, $G)) -> G {
    when size_of(G) > 0 {
        return handle.gen
    } else {
        return {}
    }
}

@(require_results)
handle_make :: #force_inline proc "contextless" ($T: typeid/Handle($I, $G), index: I, gen: G) -> Handle(I, G) {
    when size_of(G) > 0 {
        return {value = I(gen) | (index << (size_of(G) * 8))}
    } else {
        return {value = index}
    }
}
