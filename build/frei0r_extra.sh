#!/bin/bash
# Custom build hooks for frei0r, sourced automatically by the suite's
# check_custom_patches (media-suite_helper.sh) when frei0r-git is built.
#
# frei0r's SSE4.1 code (e.g. src/filter/tint0r/tint0r.c) mixes the __m128
# and __m128i vector types. That only compiles where lax vector conversions
# are the default (clang); MSYS2's GCC 16 rejects it with:
#   error: incompatible type for argument 2 of '_mm_storeu_si128'
# Building frei0r with -flax-vector-conversions makes GCC accept the same
# implicit vector bit-casts clang does, fixing every affected filter without
# patching frei0r sources. Scoped to this package only: the hooks restore
# CFLAGS and remove themselves after frei0r's cmake configure has run.

_pre_cmake() {
    _frei0r_saved_cflags=$CFLAGS
    export CFLAGS="$CFLAGS -flax-vector-conversions"
}

_post_cmake() {
    export CFLAGS=$_frei0r_saved_cflags
    unset _frei0r_saved_cflags
    unset -f _pre_cmake _post_cmake
}
