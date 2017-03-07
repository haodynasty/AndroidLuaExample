package com.plusub.androidluaexample;

import android.content.res.Resources;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.keplerproject.luajava.LuaException;
import org.keplerproject.luajava.LuaState;
import org.keplerproject.luajava.LuaStateFactory;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * lua5.3之前实现位运算：http://lua-users.org/wiki/BitwiseOperators
 *https://github.com/mkottman/AndroLua
 *https://github.com/vimfung/LuaScriptCore一个更新的方案，同时支持android，ios
 */
public class MainActivity extends ActionBarActivity {

    private LuaState mLuaState;//Lua解析和执行由此对象完成


    private TextView displayResult1;//用于演示，显示数据
    private TextView displayResult2;
    private LinearLayout mLayout;

    private static int count;
    boolean isReload = false;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        displayResult1 = (TextView)findViewById(R.id.displayResult1);
        displayResult2 = (TextView)findViewById(R.id.displayResult2);
        mLayout = (LinearLayout) findViewById(R.id.layout);


        findViewById(R.id.executeLuaStatemanet).setOnClickListener(listener);
        findViewById(R.id.executeLuaFile).setOnClickListener(listener);
        findViewById(R.id.callAndroidApi).setOnClickListener(listener);
        findViewById(R.id.clearBtn).setOnClickListener(listener);
        findViewById(R.id.executeLuaFile2).setOnClickListener(listener);
        initLua();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mLuaState != null && !mLuaState.isClosed()) {
            //只能在退出应用时才调用
            mLuaState.close();
        }
    }

    /**
     * 只是在第一次调用，如果升级脚本也不需要重复初始化
     */
    private void initLua(){
        mLuaState = LuaStateFactory.newLuaState();
        mLuaState.openLibs();
        //为了lua能使用系统日志，传入Log
        try {
            //push一个对象到对象到栈中
            mLuaState.pushObjectValue(Log.class);
            //设置为全局变量
            mLuaState.setGlobal("Log");
        } catch (LuaException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
    }

    private View.OnClickListener listener=new View.OnClickListener() {

        @Override
        public void onClick(View v) {
            switch (v.getId()) {
                case R.id.executeLuaStatemanet:
                    executeLuaStatemanet();
                    testAlgorithm();
                    break;

                case R.id.executeLuaFile:
                    executeLuaFile();
                    break;

                case R.id.callAndroidApi:
                    callAndroidAPI();
                    break;

                case R.id.clearBtn:
                    displayResult1.setText("");
                    displayResult2.setText("");
                    mLayout.removeAllViews();
                    break;
                case R.id.executeLuaFile2:
                    reloadLuaFile();
                    break;
            }
        }
    };

    private void executeLuaStatemanet()
    {
        mLuaState.LdoString(" varSay = 'This is string in lua script statement.'");// 定义一个Lua变量
        mLuaState.getGlobal("varSay");// 获取
        displayResult1.setText(mLuaState.toString(-1));// 输出
    }

    private void executeLuaFile()
    {
        try {
            //载入脚本
            mLuaState.LdoString(readStream(getResources().openRawResource(R.raw.luafile)));

            //执行函数
            mLuaState.getGlobal("functionInLuaFile");
            mLuaState.pushString("from Java params");// 将参数压入栈
            // functionInLuaFile函数有一个参数，一个返回结果
            int paramCount = 1;
            int resultCount = 1;
            mLuaState.call(paramCount, resultCount);
            displayResult2.setText(mLuaState.toString(-1));// 输出

            mLuaState.getGlobal("GetVersion");
            mLuaState.pushString("reload lua test");// 将参数压入栈
//            mLuaState.pushInteger(10);//不能输入int
//            mLuaState.pushString("10");
            mLuaState.pushNumber(10);
            int retCode = mLuaState.pcall(2, 1, -1);
            String result = mLuaState.toString(-1);
            //retCode=0表示正确调用，否则有异常
            if (retCode == 0){
                if (result == null){
                    System.out.println("GetVersion return empty value");
                }else {
                    System.out.println("GetVersion return value"+result);
                }
            }else {
                System.out.println("error:"+result+" code:"+retCode);
            }

            //test error
            mLuaState.getGlobal("testErrorHandler");
            mLuaState.call(0, 0);
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    private void reloadLuaFile(){
        //realse
        if (isReload){
            isReload = false;
//            initLua();//不需要重复初始化，只需要重新载入脚本就可以了
            executeReloadLuaFile(R.raw.luafile1);
        }else {
            isReload = true;
//            initLua();
            executeReloadLuaFile(R.raw.luafile);
        }
    }

    private void executeReloadLuaFile(int rawLuaFile)
    {
        try {
            //载入脚本
            mLuaState.LdoString(readStream(getResources().openRawResource(rawLuaFile)));

            //执行函数
            mLuaState.getGlobal("reloadMethod");
            mLuaState.pushString("");
            mLuaState.pushString("reload lua test");// 将参数压入栈
            mLuaState.call(2, 1);
            displayResult2.setText(mLuaState.toString(-1));// 输出
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    private void callAndroidAPI()
    {
        //读取文件
        mLuaState.LdoString(readStream(getResources().openRawResource(R.raw.luafile)));
        //获取函数
        mLuaState.getGlobal("callAndroidApi");
        //传入三个参数
        mLuaState.pushJavaObject(getApplicationContext());
        mLuaState.pushJavaObject(mLayout);
        mLuaState.pushString("lua调用 android , TextView的数据:" + (++count));
        //调用函数
        mLuaState.call(3, 0);
    }

    private void testAlgorithm(){
        InputStream is = null;
        try {
            is = getResources().getAssets().open("ObjectAlgorithm.lua");
            int result = mLuaState.LdoString(readStream(is));
            System.out.println("result:"+result);

            if (result == 0){
                mLuaState.getGlobal("insertData");
                mLuaState.pushString("1.1");
                mLuaState.pushString("2.0");
                mLuaState.pushString("1.326");
                mLuaState.call(3, 0);

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("0.1096");
                mLuaState.pushString("20");
                mLuaState.pushString("2");
                mLuaState.call(3, 0);

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("11");
                mLuaState.pushString("2.332");
                mLuaState.pushString("3");
                mLuaState.call(3, 0);

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("1.1");
                mLuaState.pushString("2.32");
                mLuaState.pushString("4");
                mLuaState.call(3, 0);

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("1.11");
                mLuaState.pushString("22");
                mLuaState.pushString("5");
                mLuaState.call(3, 0);

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("111.1");
                mLuaState.pushString("22");
                mLuaState.pushString("6");
                mLuaState.call(3, 0);

                System.out.println("input 7");

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("13.11");
                mLuaState.pushString("2.2");
                mLuaState.pushString("7.33");
                mLuaState.call(3, 0);

                mLuaState.getGlobal("printResult");
                mLuaState.call(0, 0);

                System.out.println("input 8");

                mLuaState.getGlobal("insertData");
                mLuaState.pushString("1.11111");
                mLuaState.pushString("2.256");
                mLuaState.pushString("0.83332");
                mLuaState.call(3, 0);

                System.out.println("input 8 over");

                mLuaState.getGlobal("printResult");
                mLuaState.call(0, 0);

                mLuaState.getGlobal("isDataEnable");
                mLuaState.call(0, 1);
                System.out.println("---isDataEnable:"+mLuaState.toString(-1));

                //获取多个返回数据
                mLuaState.getGlobal("getResult");
                mLuaState.call(0, 1);
                System.out.println("---"+mLuaState.toString(-1));
//                mLuaState.setField(LuaState.LUA_GLOBALSINDEX, "list");
//                LuaObject lObj2 = mLuaState.getLuaObject("list");
//                System.out.println("==="+lObj2.isTable()+" "+lObj2.toString());
//                int i=1;
//                LuaObject value = null;
//                try{
//                    do{
//                        value = mLuaState.getLuaObject(lObj2, i);
//                        System.out.println("===="+i+":"+value+" "+value.isBoolean()+" "+value.isNumber()+" "+value.isString());
//                        i++;
//                    }while (!value.isNil());
//                }catch (LuaException e){
//                    e.printStackTrace();
//                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            try {
                is.close();
                mLuaState.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    }


    private String readStream(InputStream is)
    {
        try {
            ByteArrayOutputStream bo = new ByteArrayOutputStream();
            int i = is.read();
            while (i != -1)
            {
                bo.write(i);
                i = is.read();
            }
            return bo.toString();
        } catch (IOException e) {
            Log.e("ReadStream", "读取文件流失败");
            return "";
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * 将/res/raw下面的资源复制到 /data/data/applicaton.package.name/files
     */
    private void copyResourcesToLocal() {
        String name, sFileName;
        InputStream content;
        R.raw a = new R.raw();
        java.lang.reflect.Field[] t = R.raw.class.getFields();
        Resources resources = getResources();
        for (int i = 0; i < t.length; i++) {
            FileOutputStream fs = null;
            try {
                name = resources.getText(t[i].getInt(a)).toString();
                sFileName = name.substring(name.lastIndexOf('/') + 1, name
                        .length());
                content = getResources().openRawResource(t[i].getInt(a));

                // Copies script to internal memory only if changes were made
                sFileName = getApplicationContext().getFilesDir() + "/"
                        + sFileName;

                Log.d("Copy Raw File", "Copying from stream " + sFileName);
                content.reset();
                int bytesum = 0;
                int byteread = 0;
                fs = new FileOutputStream(sFileName);
                byte[] buffer = new byte[1024];
                while ((byteread = content.read(buffer)) != -1) {
                    bytesum += byteread; // 字节数 文件大小
                    System.out.println(bytesum);
                    fs.write(buffer, 0, byteread);
                }
                fs.close();
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }
}
