// Lean compiler output
// Module: init.data.rbmap.default
// Imports: init.data.rbtree.default init.data.rbmap.basic
#include "runtime/object.h"
#include "runtime/apply.h"
#include "runtime/io.h"
#include "kernel/builtin.h"
typedef lean::object obj;
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#endif
void initialize_init_data_rbtree_default();
void initialize_init_data_rbmap_basic();
static bool _G_initialized = false;
void initialize_init_data_rbmap_default() {
 if (_G_initialized) return;
 _G_initialized = true;
 initialize_init_data_rbtree_default();
 initialize_init_data_rbmap_basic();
}
