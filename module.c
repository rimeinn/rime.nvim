#include <lualib.h>
#include <lauxlib.h>

int luaopen_rime(lua_State* L) {
    lua_pushstring(L, "hello");
    return 1;
}
