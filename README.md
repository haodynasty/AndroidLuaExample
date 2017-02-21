# AndroidLuaExample
update to Lua 5.3.3 and LuaJava ported to Android example

[![Download][bintray_svg]][bintray_url]

# Import
add to build.gradle,${latest.version} is [![Download][bintray_svg]][bintray_url]
```
dependencies {
    compile 'com.blakequ.luajava:luajava:${latest.version}'
}
```
maven
```
<dependency>
  <groupId>com.blakequ.luajava</groupId>
  <artifactId>luajava</artifactId>
  <version>${latest.version}</version>
  <type>pom</type>
</dependency>
```


# How to use
you can download example and study how to use

## 1. init lua

init lua file only once after start app
```
private void initLua(){
        mLuaState = LuaStateFactory.newLuaState();
        mLuaState.openLibs();
        //push Log object to lua, in lua using like: Log:i(TAG, "this log can show in AS logcat window")
        try {
            mLuaState.pushObjectValue(Log.class);
            mLuaState.setGlobal("Log");
        } catch (LuaException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
    }
```

## 2. add lua file to raw
```
app/src/main/res/raw/luafile.lua

function GetVersion(info, intvalue)
    Log:i("LuaLog", info..intvalue)
    print('this log')
    return 1
end
```

## 3. invoke lua function
```
private void executeLuaFile()
    {
            mLuaState.getGlobal("GetVersion");
            mLuaState.pushString("reload lua test");// input params
            mLuaState.pushNumber(10);
            mLuaState.call(2, 1);//2 input, 1 output
            String result = mLuaState.toString(-1);
            if (result == null){
                System.out.println("GetVersion return empty value");
            }else {
                System.out.println("GetVersion return value"+result);
            }
    }
```

# Link
- [AndroLua-mkottman](https://github.com/mkottman/AndroLua)
- [AndroLua-new](https://github.com/lendylongli/AndroLua)
- [LuaScriptCore](https://github.com/vimfung/LuaScriptCore)


[bintray_svg]: https://api.bintray.com/packages/haodynasty/maven/AndroidLua/images/download.svg
[bintray_url]: https://bintray.com/haodynasty/maven/AndroidLua/_latestVersion