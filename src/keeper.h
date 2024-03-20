#pragma once

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
#include "lua.h"
#ifdef __cplusplus
}
#endif // __cplusplus

#include "threading.h"
#include "uniquekey.h"

// forwards
struct Universe;
enum LookupMode;

struct Keeper
{
    MUTEX_T keeper_cs;
    lua_State* L;
    //int count;
};

struct Keepers
{
    int nb_keepers;
    Keeper keeper_array[1];
};

void init_keepers( Universe* U, lua_State* L);
void close_keepers( Universe* U);

Keeper* which_keeper( Keepers* keepers_, ptrdiff_t magic_);
Keeper* keeper_acquire( Keepers* keepers_, ptrdiff_t magic_);
#define KEEPER_MAGIC_SHIFT 3
void keeper_release( Keeper* K);
void keeper_toggle_nil_sentinels( lua_State* L, int val_i_, LookupMode const mode_);
int keeper_push_linda_storage( Universe* U, lua_State* L, void* ptr_, ptrdiff_t magic_);

// crc64/we of string "NIL_SENTINEL" generated at http://www.nitrxgen.net/hashgen/
static constexpr UniqueKey NIL_SENTINEL{ 0x7eaafa003a1d11a1ull };

using keeper_api_t = lua_CFunction;
#define KEEPER_API( _op) keepercall_ ## _op
#define PUSH_KEEPER_FUNC lua_pushcfunction
// lua_Cfunctions to run inside a keeper state (formerly implemented in Lua)
int keepercall_clear( lua_State* L);
int keepercall_send( lua_State* L);
int keepercall_receive( lua_State* L);
int keepercall_receive_batched( lua_State* L);
int keepercall_limit( lua_State* L);
int keepercall_get( lua_State* L);
int keepercall_set( lua_State* L);
int keepercall_count( lua_State* L);

int keeper_call(Universe* U, lua_State* K, keeper_api_t _func, lua_State* L, void* linda, int starting_index);
