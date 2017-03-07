# AndroidLuaExample
update to Lua 5.3.3 and LuaJava ported to Android example

[![License][licence_svg]][licence_url]
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
you can download example and study how to use. 
add proguard rules
```
# luajava
-keep class org.keplerproject.luajava.**{*;}
# For native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
```

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

## 4. invoke lua and error handle
```
private void executeLuaFile2()
    {
            //in lua file not exist this method:GetNotMethod
            mLuaState.getGlobal("GetNotMethod");
            mLuaState.pushString("reload lua test");// input params
            mLuaState.pushNumber(10);//not use pushInteger
            //if using call will throw exception(can not catch), so you must use pcall
            //success to invoke method if return 0, otherwise is error.
            int retCode = mLuaState.pcall(2, 1, -1);//2 input, 1 output
            String result = mLuaState.toString(-1);
            if (retCode != 0){
                LogUtils.e(TAG, "Fail to invoke GetNotMethod by lua errorCode:"+retCode+" errorMsg:"+result);
            }else {
                if (result == null){
                    System.out.println("GetVersion return empty value");
                }else {
                    System.out.println("GetVersion return value"+result);
                }
            }
    }
```

# Link
- [AndroLua-mkottman](https://github.com/mkottman/AndroLua)
- [AndroLua-new](https://github.com/lendylongli/AndroLua)
- [LuaScriptCore](https://github.com/vimfung/LuaScriptCore)


[bintray_svg]: https://api.bintray.com/packages/haodynasty/maven/AndroidLua/images/download.svg
[bintray_url]: https://bintray.com/haodynasty/maven/AndroidLua/_latestVersion
[licence_svg]: https://img.shields.io/badge/license-Apache%202-green.svg
[licence_url]: https://www.apache.org/licenses/LICENSE-2.0
