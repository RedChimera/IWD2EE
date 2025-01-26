
IEex_ReadByte = IEex_ReadU8
IEex_ReadWord = IEex_ReadU16
IEex_ReadDword = IEex_ReadU32

IEex_ReadSignedByte = IEex_Read8
IEex_ReadSignedWord = IEex_Read16

IEex_DefineAssemblyLabel("_g_lua", IEex_Label("Hardcoded_InternalLuaState"))
IEex_DefineAssemblyLabel("_lua_createtable", IEex_Label("Hardcoded_lua_createtable"))
IEex_DefineAssemblyLabel("_lua_getfield", IEex_Label("Hardcoded_lua_getfield"))
IEex_DefineAssemblyLabel("_lua_getglobal", IEex_Label("Hardcoded_lua_getglobal"))
IEex_DefineAssemblyLabel("_lua_gettop", IEex_Label("Hardcoded_lua_gettop"))
IEex_DefineAssemblyLabel("_lua_objlen", IEex_Label("Hardcoded_lua_rawlen"))
IEex_DefineAssemblyLabel("_lua_pcall", IEex_Label("Hardcoded_lua_pcall"))
IEex_DefineAssemblyLabel("_lua_pushcclosure", IEex_Label("Hardcoded_lua_pushcclosure"))
IEex_DefineAssemblyLabel("_lua_pushlightuserdata", IEex_Label("Hardcoded_lua_pushlightuserdata"))
IEex_DefineAssemblyLabel("_lua_pushlstring", IEex_Label("Hardcoded_lua_pushlstring"))
IEex_DefineAssemblyLabel("_lua_pushnumber", IEex_Label("Hardcoded_lua_pushnumber"))
IEex_DefineAssemblyLabel("_lua_pushstring", IEex_Label("Hardcoded_lua_pushstring"))
IEex_DefineAssemblyLabel("_lua_pushvalue", IEex_Label("Hardcoded_lua_pushvalue"))
IEex_DefineAssemblyLabel("_lua_rawgeti", IEex_Label("Hardcoded_lua_rawgeti"))
IEex_DefineAssemblyLabel("_lua_setfield", IEex_Label("Hardcoded_lua_setfield"))
IEex_DefineAssemblyLabel("_lua_setglobal", IEex_Label("Hardcoded_lua_setglobal"))
IEex_DefineAssemblyLabel("_lua_settable", IEex_Label("Hardcoded_lua_settable"))
IEex_DefineAssemblyLabel("_lua_settop", IEex_Label("Hardcoded_lua_settop"))
IEex_DefineAssemblyLabel("_lua_toboolean", IEex_Label("Hardcoded_lua_toboolean"))
IEex_DefineAssemblyLabel("_lua_tolstring", IEex_Label("Hardcoded_lua_tolstring"))
IEex_DefineAssemblyLabel("_lua_tonumber", IEex_Label("Hardcoded_lua_tonumber"))
IEex_DefineAssemblyLabel("_lua_touserdata", IEex_Label("Hardcoded_lua_touserdata"))
IEex_DefineAssemblyLabel("_lua_type", IEex_Label("Hardcoded_lua_type"))
IEex_DefineAssemblyLabel("_lua_typename", IEex_Label("Hardcoded_lua_typename"))
IEex_DefineAssemblyLabel("_luaL_loadfilex", IEex_Label("Hardcoded_luaL_loadfilex"))
IEex_DefineAssemblyLabel("_luaL_loadstring", IEex_Label("Hardcoded_luaL_loadstring"))
IEex_DefineAssemblyLabel("_luaL_newstate", IEex_Label("Hardcoded_luaL_newstate"))
IEex_DefineAssemblyLabel("_luaL_openlibs", IEex_Label("Hardcoded_luaL_openlibs"))

IEex_DefineAssemblyLabel("_free", IEex_Label("Hardcoded_free"))
IEex_DefineAssemblyLabel("_malloc", IEex_Label("Hardcoded_malloc"))
IEex_DefineAssemblyLabel("__ftol2_sse", IEex_GetProcAddress("msvcrt.dll", "_ftol2_sse"))
