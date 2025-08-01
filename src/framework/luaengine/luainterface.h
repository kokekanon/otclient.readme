/*
 * Copyright (c) 2010-2025 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once

#include "declarations.h"

#ifdef __has_include

#if __has_include("luajit/lua.hpp")
#include <luajit/lua.hpp>
#elif __has_include(<lua.hpp>)
#include <lua.hpp>
#elif defined(__EMSCRIPTEN__)
extern "C" {
#include <lua51/lua.h>
#include <lua51/lualib.h>
#include <lua51/lauxlib.h>
}
#define LUAJIT_VERSION = "LUA 5.1"
#else
#error "Cannot detect luajit library"
#endif

#else
#include <lua.hpp>
#endif

#if LUA_VERSION_NUM >= 502
#ifndef LUA_COMPAT_ALL
#ifndef LUA_COMPAT_MODULE
#define luaL_register(L, libname, l) (luaL_newlib(L, l), lua_pushvalue(L, -1), lua_setglobal(L, libname))
#endif
#undef lua_equal
#define lua_equal(L, i1, i2) lua_compare(L, (i1), (i2), LUA_OPEQ)
#endif
#endif

struct lua_State;
using LuaCFunction = int(*) (lua_State* L);

/// Class that manages LUA stuff
class LuaInterface
{
public:
    LuaInterface() = default;
    ~LuaInterface() = default;

    void init();
    void terminate();

    // functions that will register all script stuff in lua global environment
    void registerSingletonClass(std::string_view className);
    void registerClass(std::string_view className, std::string_view baseClass = "LuaObject");

    void registerClassStaticFunction(std::string_view className,
                                     std::string_view functionName,
                                     const LuaCppFunction& function);

    void registerClassMemberFunction(std::string_view className,
                                     std::string_view functionName,
                                     const LuaCppFunction& function);

    void registerClassMemberField(std::string_view className,
                                  std::string_view field,
                                  const LuaCppFunction& getFunction,
                                  const LuaCppFunction& setFunction);

    void registerGlobalFunction(std::string_view functionName,
                                const LuaCppFunction& function);

    // register shortcuts using templates
    template<class C, class B = LuaObject>
    void registerClass()
    {
        registerClass(stdext::demangle_class<C>(), stdext::demangle_class<B>());
    }

    template<class C>
    void registerClassStaticFunction(const std::string_view functionName, const LuaCppFunction& function)
    {
        registerClassStaticFunction(stdext::demangle_class<C>(), functionName, function);
    }

    template<class C>
    void registerClassMemberFunction(const std::string_view functionName, const LuaCppFunction& function)
    {
        registerClassMemberFunction(stdext::demangle_class<C>(), functionName, function);
    }

    template<class C>
    void registerClassMemberField(const std::string_view field,
                                  const LuaCppFunction& getFunction,
                                  const LuaCppFunction& setFunction)
    {
        registerClassMemberField(stdext::demangle_class<C>(), field, getFunction, setFunction);
    }

    // methods for binding functions
    template<class C, typename F>
    void bindSingletonFunction(std::string_view functionName, F C::* function, C* instance);
    template<class C, typename F>
    void bindSingletonFunction(std::string_view className, std::string_view functionName, F C::* function, C* instance);

    template<class C, typename F>
    void bindClassStaticFunction(std::string_view functionName, const F& function);
    template<typename F>
    void bindClassStaticFunction(std::string_view className, std::string_view functionName, const F& function);

    template<class C, typename F, class FC>
    void bindClassMemberFunction(std::string_view functionName, F FC::* function);
    template<class C, typename F, class FC>
    void bindClassMemberFunction(std::string_view className, std::string_view functionName, F FC::* function);

    template<class C, typename F1, typename F2, class FC>
    void bindClassMemberField(std::string_view fieldName, F1 FC::* getFunction, F2 FC::* setFunction);
    template<class C, typename F1, typename F2, class FC>
    void bindClassMemberField(std::string_view className, std::string_view fieldName, F1 FC::* getFunction, F2 FC::* setFunction);

    template<class C, typename F, class FC>
    void bindClassMemberGetField(std::string_view fieldName, F FC::* getFunction);
    template<class C, typename F, class FC>
    void bindClassMemberGetField(std::string_view className, std::string_view fieldName, F FC::* getFunction);

    template<class C, typename F, class FC>
    void bindClassMemberSetField(std::string_view fieldName, F FC::* setFunction);
    template<class C, typename F, class FC>
    void bindClassMemberSetField(std::string_view className, std::string_view fieldName, F FC::* setFunction);

    template<typename F>
    void bindGlobalFunction(std::string_view functionName, const F& function);

private:
    /// Metamethod that will retrieve fields values (that include functions) from the object when using '.' or ':'
    static int luaObjectGetEvent(LuaInterface* lua);
    /// Metamethod that is called when setting a field of the object by using the keyword '='
    static int luaObjectSetEvent(LuaInterface* lua);
    /// Metamethod that will check equality of objects by using the keyword '=='
    static int luaObjectEqualEvent(LuaInterface* lua);
    /// Metamethod that is called every two lua garbage collections
    /// for any LuaObject that have no references left in lua environment
    /// anymore, thus this creates the possibility of holding an object
    /// existence by lua until it got no references left
    static int luaObjectCollectEvent(LuaInterface* lua);

public:
    /// Loads and runs a script, any errors are printed to stdout and returns false
    bool safeRunScript(const std::string& fileName);

    /// Loads and runs a script
    /// @exception LuaException is thrown on any lua error
    void runScript(const std::string& fileName);

    /// Loads and runs the script from buffer
    /// @exception LuaException is thrown on any lua error
    void runBuffer(std::string_view buffer, std::string_view source);

    /// Loads a script file and pushes it's main function onto stack,
    /// @exception LuaException is thrown on any lua error
    void loadScript(const std::string& fileName);

    /// Loads a function from buffer and pushes it onto stack,
    /// @exception LuaException is thrown on any lua error
    void loadFunction(std::string_view buffer, std::string_view source = "lua function buffer");

    /// Evaluates a lua expression and pushes the result value onto the stack
    /// @exception LuaException is thrown on any lua error
    void evaluateExpression(std::string_view expression, std::string_view source = "lua expression");

    /// Generates a traceback message for the current call stack
    /// @param errorMessage is an additional error message
    /// @param level is the level of the traceback, 0 means trace from calling function
    /// @return the generated traceback message
    std::string traceback(std::string_view errorMessage = "", int level = 0);

    /// Throw a lua error if inside a lua call or generates an C++ stdext::exception
    /// @param message is the error message wich will be displayed before the error traceback
    /// @exception stdext::exception is thrown with the error message if the error is not captured by lua
    void throwError(std::string_view message);

    /// Searches for the source of the current running function
    std::string getCurrentSourcePath(int level = 0);

    /// @brief Calls a function
    /// The function and arguments must be on top of the stack in order,
    /// results are pushed onto the stack.
    /// @exception LuaException is thrown on any lua error
    /// @return number of results
    int safeCall(int numArgs = 0, int numRets = -1);

    /// Same as safeCall but catches exceptions and can also calls a table of functions,
    /// if any error occurs it will be reported to stdout and returns 0 results
    /// @param requestedResults is the number of results requested to pushes onto the stack,
    /// if supplied, the call will always pushes that number of results, even if it fails
    int signalCall(int numArgs = 0, int numRets = -1);

    /// @brief Creates a new environment table
    /// The new environment table is redirected to the global environment (aka _G),
    /// this allows to access global variables from _G in the new environment and
    /// prevents new variables in this new environment to be set on the global environment
    int newSandboxEnv();

    template<typename... T>
    int luaCallGlobalField(std::string_view global, std::string_view field, const T&... args);

    template<typename... T>
    void callGlobalField(std::string_view global, std::string_view field, const T&... args);

    template<typename R, typename... T>
    R callGlobalField(std::string_view global, std::string_view field, const T&... args);

    bool isInCppCallback() const { return m_cppCallbackDepth != 0; }

private:
    /// Load scripts requested by lua 'require'
    static int luaScriptLoader(lua_State* L);
    /// Run scripts requested by lua 'dofile'
    static int lua_dofile(lua_State* L);
    /// Run scripts requested by lua 'dofiles'
    static int lua_dofiles(lua_State* L);
    /// Run scripts requested by lua 'dofiles'
    static int lua_loadfile(lua_State* L);
    /// Handle lua errors from safeCall
    static int luaErrorHandler(lua_State* L);
    /// Handle bound cpp functions callbacks
    static int luaCppFunctionCallback(lua_State* L);
    /// Collect bound cpp function pointers
    static int luaCollectCppFunction(lua_State* L);

    // Bit functions
#ifndef LUAJIT_VERSION
    static int luaBitAnd(lua_State* L);
    static int luaBitNot(lua_State* L);
    static int luaBitOr(lua_State* L);
    static int luaBitXor(lua_State* L);
    static int luaBitRightShift(lua_State* L);
    static int luaBitLeftShift(lua_State* L);
#endif

public:
    void registerTable(lua_State* L, const std::string& tableName);
    void registerMethod(lua_State* L, const std::string& globalName, const std::string& methodName, lua_CFunction func);

    void createLuaState();
    void closeLuaState();

    void collectGarbage() const;

    void loadBuffer(std::string_view buffer, std::string_view source);

    int pcall(int numArgs = 0, int numRets = 0, int errorFuncIndex = 0);
    void call(int numArgs = 0, int numRets = 0);
    void error();

    int ref() const;
    int weakRef();
    void unref(int ref) const;
    void useValue() { pushValue(); ref(); }

    const char* typeName(int index = -1);
    std::string functionSourcePath() const;

    void insert(int index);
    void remove(int index);
    bool next(int index = -2);

    void checkStack() const { assert(getTop() <= 20); }
    void getStackFunction(int level = 0);

    void getRef(int ref) const;
    void getWeakRef(int weakRef);

    int getGlobalEnvironment() const { return m_globalEnv; }
    void setGlobalEnvironment(int env);
    void resetGlobalEnvironment() { setGlobalEnvironment(m_globalEnv); }

    void setMetatable(int index = -2);
    void getMetatable(int index = -1);

    void getField(std::string_view key, int index = -1);
    void setField(std::string_view key, int index = -2);

    void getTable(int index = -2);
    void setTable(int index = -3);
    void clearTable(int index = -1);

    void getEnv(int index = -1);
    void setEnv(int index = -2);

    void getGlobal(std::string_view key) const;
    void getGlobalField(std::string_view globalKey, std::string_view fieldKey);
    void setGlobal(std::string_view key);

    void rawGet(int index = -1);
    void rawGeti(int n, int index = -1);
    void rawSet(int index = -3);
    void rawSeti(int n, int index = -2);

    void newTable() const;
    void createTable(int narr, int nrec) const;
    void* newUserdata(int size) const;

    void pop(int n = 1);
    long popInteger();
    double popNumber();
    bool popBoolean();
    std::string popString();
    void* popUserdata();
    void* popUpvalueUserdata() const;
    LuaObjectPtr popObject();

    void pushNil();
    void pushInteger(long v);
    void pushNumber(double v);
    void pushBoolean(bool v);
    void pushString(std::string_view v);
    void pushLightUserdata(void* p);
    void pushThread();
    void pushValue(int index = -1);
    void pushObject(const LuaObjectPtr& obj);
    void pushCFunction(LuaCFunction func, int n = 0);
    void pushCppFunction(const LuaCppFunction& func);

    bool isNil(int index = -1);
    bool isBoolean(int index = -1);
    bool isNumber(int index = -1);
    bool isString(int index = -1);
    bool isTable(int index = -1);
    bool isFunction(int index = -1);
    bool isCFunction(int index = -1);
    bool isLuaFunction(const int index = -1) { return (isFunction(index) && !isCFunction(index)); }
    bool isUserdata(int index = -1);

    bool toBoolean(int index = -1);
    int toInteger(int index = -1);
    double toNumber(int index = -1);
    std::string_view toVString(int index = -1);
    std::string toString(int index = -1);
    void* toUserdata(int index = -1);
    LuaObjectPtr toObject(int index = -1);

    int getTop() const;
    int stackSize() const { return getTop(); }
    void clearStack() { pop(stackSize()); }
    bool hasIndex(const int index) { return (stackSize() >= (index < 0 ? -index : index) && index != 0); }

    std::string getSource(int level = 2);

    void loadFiles(const std::string& directory, bool recursive = false, const std::string& contains = "");

    /// Pushes any type onto the stack
    template<typename T, typename... Args>
    int polymorphicPush(const T& v, const Args&... args);
    int polymorphicPush() { return 0; }

    /// Casts a value from stack to any type
    /// @exception LuaBadValueCastException thrown if the cast fails
    template<class T>
    T castValue(int index = -1);

    /// Same as castValue but also pops
    template<class T>
    T polymorphicPop() { T v = castValue<T>(); pop(1); return v; }

private:
    lua_State* L{ nullptr };
    int m_weakTableRef{ 0 };
    int m_cppCallbackDepth{ 0 };
    int m_totalObjRefs{ 0 };
    int m_totalFuncRefs{ 0 };
    int m_globalEnv{ 0 };
};

extern LuaInterface g_lua;

// must be included after, because they need LuaInterface fully declared
#include "luabinder.h"
#include "luaexception.h"
#include "luavaluecasts.h"

template<typename T, typename... Args>
int LuaInterface::polymorphicPush(const T& v, const Args&... args)
{
    int r = push_luavalue(v);
    return r + polymorphicPush(args...);
}

// next templates must be defined after above includes

template<class C, typename F>
void LuaInterface::bindSingletonFunction(const std::string_view functionName, F C::* function, C* instance)
{
    registerClassStaticFunction<C>(functionName, luabinder::bind_singleton_mem_fun(function, instance));
}

template<class C, typename F>
void LuaInterface::bindSingletonFunction(const std::string_view className, const std::string_view functionName, F C::* function, C* instance)
{
    registerClassStaticFunction(className, functionName, luabinder::bind_singleton_mem_fun(function, instance));
}

template<class C, typename F>
void LuaInterface::bindClassStaticFunction(const std::string_view functionName, const F& function)
{
    registerClassStaticFunction<C>(functionName, luabinder::bind_fun(function));
}
template<typename F>
void LuaInterface::bindClassStaticFunction(const std::string_view className, const std::string_view functionName, const F& function)
{
    registerClassStaticFunction(className, functionName, luabinder::bind_fun(function));
}

template<class C, typename F, class FC>
void LuaInterface::bindClassMemberFunction(const std::string_view functionName, F FC::* function)
{
    registerClassMemberFunction<C>(functionName, luabinder::bind_mem_fun<C>(function));
}
template<class C, typename F, class FC>
void LuaInterface::bindClassMemberFunction(const std::string_view className, const std::string_view functionName, F FC::* function)
{
    registerClassMemberFunction(className, functionName, luabinder::bind_mem_fun<C>(function));
}

template<class C, typename F1, typename F2, class FC>
void LuaInterface::bindClassMemberField(const std::string_view fieldName, F1 FC::* getFunction, F2 FC::* setFunction)
{
    registerClassMemberField<C>(fieldName, luabinder::bind_mem_fun<C>(getFunction), luabinder::bind_mem_fun<C>(setFunction));
}
template<class C, typename F1, typename F2, class FC>
void LuaInterface::bindClassMemberField(const std::string_view className, const std::string_view fieldName, F1 FC::* getFunction, F2 FC::* setFunction)
{
    registerClassMemberField(className, fieldName, luabinder::bind_mem_fun<C>(getFunction), luabinder::bind_mem_fun<C>(setFunction));
}

template<class C, typename F, class FC>
void LuaInterface::bindClassMemberGetField(const std::string_view fieldName, F FC::* getFunction)
{
    registerClassMemberField<C>(fieldName, luabinder::bind_mem_fun<C>(getFunction), LuaCppFunction());
}
template<class C, typename F, class FC>
void LuaInterface::bindClassMemberGetField(const std::string_view className, const std::string_view fieldName, F FC::* getFunction)
{
    registerClassMemberField(className, fieldName, luabinder::bind_mem_fun<C>(getFunction), LuaCppFunction());
}

template<class C, typename F, class FC>
void LuaInterface::bindClassMemberSetField(const std::string_view fieldName, F FC::* setFunction)
{
    registerClassMemberField<C>(fieldName, LuaCppFunction(), luabinder::bind_mem_fun<C>(setFunction));
}
template<class C, typename F, class FC>
void LuaInterface::bindClassMemberSetField(const std::string_view className, const std::string_view fieldName, F FC::* setFunction)
{
    registerClassMemberField(className, fieldName, LuaCppFunction(), luabinder::bind_mem_fun<C>(setFunction));
}

template<typename F>
void LuaInterface::bindGlobalFunction(const std::string_view functionName, const F& function)
{
    registerGlobalFunction(functionName, luabinder::bind_fun(function));
}

template<class T>
T LuaInterface::castValue(int index)
{
    T o;
    if constexpr (std::is_same_v<T, std::string_view>) {
        o = g_lua.toVString(index);
    } else if (!luavalue_cast(index, o))
        throw LuaBadValueCastException(typeName(index), stdext::demangle_type<T>());
    return o;
}

template<typename... T>
int LuaInterface::luaCallGlobalField(const std::string_view global, const std::string_view field, const T&... args)
{
    g_lua.getGlobalField(global, field);
    if (!g_lua.isNil()) {
        const int numArgs = g_lua.polymorphicPush(args...);
        return g_lua.signalCall(numArgs);
    }
    g_lua.pop(1);
    return 0;
}

template<typename... T>
void LuaInterface::callGlobalField(const std::string_view global, const std::string_view field, const T&... args)
{
    if (g_luaThreadId > -1 && g_luaThreadId != stdext::getThreadId()) {
        g_logger.warning("callGlobalField(" + std::string{ global } + ", " + std::string{ field } + ") is being called outside the context of the lua call.");
        return;
    }

    const int rets = luaCallGlobalField(global, field, args...);
    if (rets > 0)
        pop(rets);
}

template<typename R, typename... T>
R LuaInterface::callGlobalField(const std::string_view global, const std::string_view field, const T&... args)
{
    if (g_luaThreadId > -1 && g_luaThreadId != stdext::getThreadId()) {
        g_logger.warning("callGlobalField(" + std::string{ global } + ", " + std::string{ field } + ") is being called outside the context of the lua call.");
        return R();
    }

    R result;
    if (const int rets = luaCallGlobalField(global, field, args...); rets > 0) {
        assert(rets == 1);
        result = g_lua.polymorphicPop<R>();
    } else
        result = R();

    return result;
}
