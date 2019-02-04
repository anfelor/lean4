// Lean compiler output
// Module: init.control.default
// Imports: init.control.applicative init.control.functor init.control.alternative init.control.monad init.control.lift init.control.state init.control.id init.control.except init.control.reader init.control.option
#include "runtime/object.h"
#include "runtime/apply.h"
#include "runtime/io.h"
#include "kernel/builtin.h"
typedef lean::object obj;
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#endif
void initialize_init_control_applicative();
void initialize_init_control_functor();
void initialize_init_control_alternative();
void initialize_init_control_monad();
void initialize_init_control_lift();
void initialize_init_control_state();
void initialize_init_control_id();
void initialize_init_control_except();
void initialize_init_control_reader();
void initialize_init_control_option();
static bool _G_initialized = false;
void initialize_init_control_default() {
 if (_G_initialized) return;
 _G_initialized = true;
 initialize_init_control_applicative();
 initialize_init_control_functor();
 initialize_init_control_alternative();
 initialize_init_control_monad();
 initialize_init_control_lift();
 initialize_init_control_state();
 initialize_init_control_id();
 initialize_init_control_except();
 initialize_init_control_reader();
 initialize_init_control_option();
}
