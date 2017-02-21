--
-- Created by IntelliJ IDEA.
-- User: PLUSUB
-- Date: 2015/10/16
-- Time: 11:09
-- To change this template use File | Settings | File Templates.
--
str = "are you china"
VERSION = 1
function functionInLuaFile(key)
    --print log
    Log:i("LuaLog", "over setcontent")
    return ' Function in Lua file . Return : '..key..'!'..str
end

function callAndroidApi(context,layout,tip)
    tv = luajava.newInstance("android.widget.TextView",context)
    tv:setText(tip)
    layout:addView(tv)
end

function reloadMethod(self, info)
    Log:i("LuaLog", "method origial "..info)
    return ' Function in Lua file.' ..info
end

function GetVersion(info, intvalue)
    Log:i("LuaLog", info..intvalue)
--  测试返回值，调用时mLuaState.call(1, 1);在这里可以是下面4中情况
--    return nil
--    return
--    没有return也没有影响
    return VERSION
end

-- 错误处理测试
function testErrorHandler()
    Log:i("LuaLog", '----xpcall有错误---')
    --  xpcall接收第二个参数——一个错误处理函数，当错误发生时，Lua会在调用桟展看（unwind）前调用错误处理函数，于是就可以在这个函数中使用debug库来获取关于错误的额外信息了
    status = xpcall(myfunction, myerrorhandler)
    Log:i("LuaLog", '----xpcall无错误带返回值---')
--  返回三个参数：状态，返回值，错误,xpcall (f, msgh [, arg1, ···])这个传入参数arg1需要5.2以上才能支持http://stackoverflow.com/questions/30125726/how-to-use-xpcall-with-a-function-which-has-parameters
    status1, ret, err = xpcall(myfunction3, myerrorhandler, 5, 6)
--  5.2以下版本不能传入参数，只能用函数包装参数
--    status1, ret, err = xpcall(myfunction4, myerrorhandler)
    Log:i("LuaLog", 'myfunction3 result '..(status1 and "true" or "false"))
    if ret ~= nil then
        Log:i("LuaLog", 'myfunction3 ret '..ret)
    end
    if err ~= nil then
        Log:i("LuaLog", 'myfunction3 err '..err)
    end

    Log:i("LuaLog", '----pcall---')
    --  pcall接收一个函数和要传递个后者的参数，并执行，执行结果：有错误、无错误；返回值true或者或false, errorinfo。
    status, err = pcall(testPcall, 33)
--    status, err = pcall(function(i) testPcall(i) end, 33)
--    if pcall(function(i) testPcall(i) end, 33) then
    if status == true then
        -- 没有错误
        Log:i("LuaLog", 'test right')
    else
        -- 一些错误
        Log:e("LuaLog", 'test error== '..err)
    end
    Log:i("LuaLog", '----end---')
end

function myfunction ()
--    n = n/nil
    myfunction2()
end

function myfunction2 ()
    n = n/nil
end

-- 5.2以上才能带参数
function myfunction3(a, b)
    if a ~= nil and b ~= nil then
        Log:i("LuaLog", 'myfunction3 value is a:'..a..' b:'..b)
        return a + b
    end
    return 0
end
-- 5.1以下要传参需要无参数
function myfunction4()
    n = n/nil
    myfunction3(1,3)
end

function myerrorhandler( err )
    Log:i("LuaLog", "ERROR:"..err..'\n'..debug.traceback("Stack trace"))
end

function testPcall(i)
    print(i)
    n = n/nil
    error('error..11 ')
end

