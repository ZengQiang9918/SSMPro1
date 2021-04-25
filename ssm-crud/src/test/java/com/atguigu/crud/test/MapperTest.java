package com.atguigu.crud.test;


import com.atguigu.crud.bean.Department;
import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.dao.DepartmentMapper;
import com.atguigu.crud.dao.EmployeeMapper;
import org.apache.ibatis.session.SqlSession;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 测试dao层的工作
 * 记得要放在test目录下
 * 推荐Spring的项目就可以使用Spring的单元测试。可以自动注入我们需要的组件
 * 1.导入Spring-Test依赖
 * 2.@ContextConfiguration指定Spring配置文件的位置
 * 3.@RunWith：它是JUnit的注解。指定Spring来运行测试
 * 4.直接@Autowired我们要使用的组件即可
 * 注意:使用SpringJUnit4ClassRunner需要Junit4.12以上包括Junit4.12的Junit版本
 */

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
public class MapperTest {

    @Autowired
    DepartmentMapper departmentMapper;

    @Autowired
    EmployeeMapper employeeMapper;

    @Autowired
    SqlSession sqlSession;

    @Test
    public void testCRUD(){
        System.out.println(departmentMapper);

        //1.插入几个部门
//        departmentMapper.insertSelective(new Department(null,"开发部"));
//        departmentMapper.insertSelective(new Department(null,"测试部"));

        //2.生成员工数据，测试员工插入
//        employeeMapper.insertSelective(new Employee(null,"Jerry","M","Jerry@atguigu.com",1));

        //3.批量插入多个员工（batch）
        //使用可以执行批量操作的SqlSession.在applicationContext中，即ioc容器中配置这个sqlSession
        /*EmployeeMapper mapper = sqlSession.getMapper(EmployeeMapper.class);
        for (int i = 0; i < 1000; i++) {
            String uid = UUID.randomUUID().toString().substring(0,5)+i;
            mapper.insertSelective(new Employee(null,uid,"M",uid+"@atguigu.com",1));
        }*/
    }
}
