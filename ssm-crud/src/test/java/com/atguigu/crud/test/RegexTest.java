package com.atguigu.crud.test;

import org.junit.Test;

import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * java中的正则表达式使用
 */

public class RegexTest {

    /**
     * 正则表达式的创建和匹配
     */
    @Test
    public void test01(){

        //正则表达式对象
        Pattern pattern = Pattern.compile("\\w+");

        //创建Matcher对象
        Matcher matcher = pattern.matcher("asdfsw&22223");
        boolean b = matcher.matches();    //尝试将整个字符序列与该模式匹配

        System.out.println(b);
    }


    /**
     * matcher.find()的用法
     */
    @Test
    public void test02(){
        //正则表达式对象
        Pattern pattern = Pattern.compile("\\w+");

        //创建Matcher对象
        Matcher matcher = pattern.matcher("asdf&&sw22223");

//        boolean b = matcher.find();   //该方法扫描输入的序列，查找与该模式匹配的下一个子序列

        System.out.println(matcher.find());   //true  匹配asdf
        System.out.println(matcher.find());   //true  匹配sw22223
        System.out.println(matcher.find());   //false 匹配不到字符序列了
    }


    /**
     * matcher.find()和matcher.group()的使用
     */
    @Test
    public void test03(){
        //正则表达式对象
        Pattern pattern = Pattern.compile("\\w+");

        //创建Matcher对象
        Matcher matcher = pattern.matcher("asdf&&sw22223");

//        System.out.println(matcher.find());   //find()函数找到group组
//        System.out.println(matcher.group());  //一定要先使用find()找到是否有匹配的子序列，再使用group()打印序列


        while (matcher.find()){
            System.out.println(matcher.group());   //group()和group(0)是一样的，表示匹配匹配上的整个字符串
            System.out.println(matcher.group(0));
        }
    }


    /**
     * matcher.group(int),分组的概念
     */
    @Test
    public void test04(){
        //正则表达式对象
        Pattern pattern = Pattern.compile("([a-z]+)([0-9]+)");

        //创建Matcher对象
        Matcher matcher = pattern.matcher("222aa**ssd445**gn88");

        while (matcher.find()){
            System.out.println(matcher.group(0));    //匹配整个表达式中匹配上的子字符串
            System.out.println(matcher.group(1));    //匹配匹配上的子字符串中的分组{分组是正则表达式中()部分}
            System.out.println(matcher.group(2));
        }

    }


    /**
     * matcher.group()的作用
     */
    @Test
    public void test04_1(){
        Pattern p = Pattern.compile("([a-z]+)([0-9]+)");
        Matcher m = p.matcher("aaaassaf0943");
        if (m.find()){
            System.out.println(m.group(0));
            System.out.println(m.group(1));
            System.out.println(m.group(2));

        }
    }


    /**
     * 测试正则表达式：替换
     */
    @Test
    public void test05(){
        //表达式对象
        Pattern p =Pattern.compile("[0-9]+");

        //创建Matcher对象
        Matcher m = p.matcher("aa223***sada222***adsa");

        String s = m.replaceAll("&&");
        System.out.println(s);
    }

    /**
     * 测试字符串正则表达式对象分割字符串的操作
     */
    @Test
    public void test06(){
        String str = "a,b,c";
        String[] strings = str.split(",");
        //System.out.println(strings);
        System.out.println(Arrays.toString(strings));


        String str2 = "a23242b23242cd2332";
        String[] strings1 = str2.split("\\d+");
        System.out.println(Arrays.toString(strings1));   //[a,b,cd]
    }

    /**
     * 最简单的正则表达式的使用
     */
    @Test
    public void test07(){
        String str="sada222";
        //使用字符串对象的方法 String.matches(regex): boolean
        boolean b = str.matches("[a-z0-9]+");
        System.out.println(b);     //true
    }


    /**
     * 测试[^]
     */
    @Test
    public void test08(){
        Pattern p = Pattern.compile("[^a-z0-9]");
        Matcher m = p.matcher("222asaf+");
//        boolean b = m.matches();
//        System.out.println(b);
        while(m.find()){
            System.out.println(m.group());
        }
    }


}
