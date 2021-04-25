package com.atguigu.crud.controller;

import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.bean.Msg;
import com.atguigu.crud.service.EmployeeService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 处理员工请求
 */
@Controller
public class EmployeeController {

    @Autowired
    EmployeeService employeeService;


    /**
     * 单个批量二合一的方法
     * 批量删除: 1-2-3
     * 单个删除：1
     * @param ids
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emp/{ids}",method = RequestMethod.DELETE)
    public Msg deleteEmp(@PathVariable("ids") String ids){
        if(ids.contains("-")){
            List<Integer> del_ids =new ArrayList<>();
            //多个的批量删除
            String[] str_ids = ids.split("-");
            //组装id
            for (String str_id : str_ids) {
                del_ids.add(Integer.parseInt(str_id));
            }

            employeeService.deleteBatch(del_ids);
        }else{
            Integer id =Integer.parseInt(ids);
            employeeService.deleteEmp(id);
        }
        return Msg.success();

    }




    /**
     * 如果直接发送ajax=put形式的请求
     * 问题：
     *   请求体中有数据
     *   但是Employee对象封装不上
     *
     * 原因：
     *   Tomcat：
     *   将请求体中的数据，封装为一个map。
     *   request.getParameter("empName")就会从这个map中取值
     *   springMVC封装POJO对象的时候
     *      会把POJO中每个属性的值，request.getParameter("email")
     *
     * AJAX发送PUT请求不能直接发
     *  put请求：请求体中的数据：request.getParameter()都拿不到
     *  根本原因：TOMCAT一看是put,就不会封装请求体中的数据为map.
     *              只有post形式的请求才封装为map.
     *
     * Tomcat的源码：
     *  org.apache.catalina.connector.Request;
     *
     * 解决方案：
     * 我们要能支持发送put之类的请求还要封装请求体中的数据
     * 配置上HttpPutFormContentFilter:
     *  作用：将请求体中的数据解析包装为一个map。
     *  request被重新包装，request.getParameter()被重写，就会从自己封装的map中取数据
     *
     *
     *
     * 员工更新方法
     * @param employee
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emp/{empId}",method = RequestMethod.PUT)
    public  Msg saveEmp(@PathVariable("empId") String empId, Employee employee,
                        HttpServletRequest request){
        //System.out.println(request.getParameter("email"));
        //System.out.println(request.getAttribute("empId"));
        //了解一下@PathVirable注解
        System.out.println(empId);
        System.out.println("将要更新的员工数据："+employee);
        employeeService.updateEmp(employee);
        return Msg.success();
    }


    /**
     *  根据id查询员工
     * @return
     */
    @RequestMapping(value = "/emp/{id}",method = RequestMethod.GET)
    @ResponseBody
    public Msg getEmp(@PathVariable("id") Integer id){
        Employee employee = employeeService.getEmp(id);
        return Msg.success().add("emp",employee);
    }


    /**
     * 检查用户名是否可用
     * @param empName
     * @return
     */
    @ResponseBody
    @RequestMapping("/checkUser")
    public Msg checkUser(String empName){
        //先判断用户名是否是合法的表达式
        //java中的正则表达式没有斜杆
        String regx ="(^[a-zA-Z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{2,5}$)";
        boolean matches = empName.matches(regx);
        if(!matches){
            return Msg.fail().add("va_msg","用户名必须是6-16位英文和数字的组合或者2-5位的中文");
        }

        //数据库用户名重复校验
        boolean b = employeeService.checkUser(empName);
        if(b){
            return Msg.success();
        }else {
            return Msg.fail().add("va_msg","用户名不可用");
        }
    }


    /**
     * 员工保存
     * 1.支持JSR303校验
     * 2.导入Hibernate-validator
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emp",method = RequestMethod.POST)
    public Msg saveEmp(@Valid Employee employee, BindingResult result){
        if(result.hasErrors()){
            //校验失败，返回失败,在模态框中显示校验失败的错误信息
            Map<String,Object> map =new HashMap<>();
            List<FieldError> errors = result.getFieldErrors();
            for (FieldError error : errors) {
                System.out.println("错误的字段名："+error.getField());
                System.out.println("错误信息："+error.getDefaultMessage());
                map.put(error.getField(),error.getDefaultMessage());
            }
            return Msg.fail().add("errorFields",map);
        }else {
            employeeService.saveEmp(employee);
            return Msg.success();
        }
    }



    /**
     * 查询员工分页信息
     * 导入json的包jackson
     * @return
     */
    @ResponseBody
    @RequestMapping(value="/emps")
    public Msg getEmpsWithJSon(@RequestParam(value = "pn",defaultValue = "1") Integer pn,
                               Model model){

        PageHelper.startPage(pn,5);
        //startPage后面紧跟的查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        //使用pageInfo包装我们查询后的结果，只需要将pageInfo交给我们的页面即可
        //pageInfo里面封装了详细的信息，包括有我们查询出来的数据
        //第二个参数为连续显示的页数。
        PageInfo page = new PageInfo(emps,5);

        //如果让我来写Msg这个类的话应该是会通过简单构造和set传参的方法设置属性
        return Msg.success().add("pageInfo",page);
    }


    /**
     * 查询员工分页查询
     * 我们将使用json字符串的形式来接收和发送数据，注掉此方法
     * @return
     */
    //@RequestMapping("/emps")
    //Model可以作为参数传给我们的处理器方法。
    public String getEmps(@RequestParam(value = "pn",defaultValue = "1") Integer pn,
                          Model model){

        //defaultValue可设置value的默认值
        //引入PageHelper分页插件
        //在查询之前只需要调用pageHelper,传入页码。以及每页的大小
        PageHelper.startPage(pn,5);
        //startPage后面紧跟的查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        //使用pageInfo包装我们查询后的结果，只需要将pageInfo交给我们的页面即可
        //pageInfo里面封装了详细的信息，包括有我们查询出来的数据
        //第二个参数为连续显示的页数。
        PageInfo page = new PageInfo(emps,5);
        model.addAttribute("pageInfo",page);
        return "list";
    }
}
