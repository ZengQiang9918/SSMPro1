package com.atguigu.crud.test;


import com.atguigu.crud.bean.Employee;
import com.github.pagehelper.PageInfo;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.util.List;


/**
 * 使用spring测试模块提供的测试请求功能
 * 测试crud请求的正确性
 */
@RunWith(SpringJUnit4ClassRunner.class)
//@WebAppConfiguration作用是能够获取WebApplicationContext
@WebAppConfiguration
@ContextConfiguration(locations = {"classpath:applicationContext.xml", "classpath:dispatcherServlet.xml"})
public class MvcTest {

    //传入Springmvc的ioc
    @Autowired
    WebApplicationContext context;

    //虚拟的mvc请求，获取到处理请求
    MockMvc mockMvc;

    //junit的注解，每次进来都执行initMockMvc
    @Before
    public void initMockMvc(){
        mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
    }

    @Test
    public void testPage() throws Exception {
        //模拟请求，拿到返回值
        MvcResult result = mockMvc.perform(MockMvcRequestBuilders.get("/emps")
                .param("pn", "5")).andReturn();

        //请求成功后，请求域中会有pageInfo,我们可以取出pageInfo进行验证
        MockHttpServletRequest request = result.getRequest();
        PageInfo pi = (PageInfo) request.getAttribute("pageInfo");
        System.out.println("当前页码："+ pi.getPageNum());
        System.out.println("总页码："+pi.getPages());
        System.out.println("总记录数："+pi.getTotal());
        System.out.println("在页面需要连续显示的页码：");
        int[] navigatepageNums = pi.getNavigatepageNums();
        for (int i : navigatepageNums) {
            System.out.print(" "+i);
        }
        System.out.println();

        //获取员工数据
        List<Employee> list = pi.getList();
        for (Employee employee : list) {
            System.out.println("ID:" + employee.getEmpId() +"==>Name:"+employee.getEmpName());
        }
    }

}
