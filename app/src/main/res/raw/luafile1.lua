--
-- Created by IntelliJ IDEA.
-- User: PLUSUB
-- Date: 2015/10/16
-- Time: 11:09
-- To change this template use File | Settings | File Templates.
--
str = "are you china"
function functionInLuaFile(key)
    --print log
    Log:i("LuaLog", "reload lua file")
    return ' Function in Lua file222222 . Return : '..key..'!'..str
end


function callAndroidApi(context,layout,tip)
    tv = luajava.newInstance("android.widget.TextView",context)
    tv:setText(tip)
    layout:addView(tv)
end

function reloadMethod(self, info)
    Log:i("LuaLog", "method reload "..info)
    return ' Function in reload Lua file.' ..info
end