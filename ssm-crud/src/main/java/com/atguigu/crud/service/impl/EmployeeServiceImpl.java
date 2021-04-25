package com.atguigu.crud.service.impl;

import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.bean.EmployeeExample;
import com.atguigu.crud.dao.EmployeeMapper;
import com.atguigu.crud.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmployeeServiceImpl implements EmployeeService {

    @Autowired
    EmployeeMapper employeeMapper;


    /**
     * 查询所有员工的记录
     * @return
     */
    @Override
    public List<Employee> getAll() {
        return employeeMapper.selectByExampleWithDept(null);
    }

    @Override
    public void saveEmp(Employee employee) {
        employeeMapper.insertSelective(employee);
    }

    /**
     * 检验用户名是否可用
     * @param empName
     * @return true:代表当前姓名可用  false:不可用
     */
    @Override
    public boolean checkUser(String empName) {
        EmployeeExample example =new EmployeeExample();
        //内部类
        EmployeeExample.Criteria criteria = example.createCriteria();
        criteria.andEmpNameEqualTo(empName);
        long count = employeeMapper.countByExample(example);
        return count ==0;
    }


    /**
     * 按照员工ID查询员工
     * @param id
     * @return
     */
    @Override
    public Employee getEmp(Integer id) {
        Employee employee = employeeMapper.selectByPrimaryKey(id);
        return employee;
    }


    @Override
    public void updateEmp(Employee employee) {
        employeeMapper.updateByPrimaryKeySelective(employee);
    }


    /**
     * 删除员工
     * @param id
     */
    @Override
    public void deleteEmp(Integer id) {
        employeeMapper.deleteByPrimaryKey(id);
    }


    /**
     * 批量删除员工
     * @param ids
     */
    @Override
    public void deleteBatch(List<Integer> ids) {
        //按条件删除
        EmployeeExample example = new EmployeeExample();
        EmployeeExample.Criteria criteria = example.createCriteria();
        //delete from xxx where emp_id in (1,2,3);
        criteria.andEmpIdIn(ids);
        employeeMapper.deleteByExample(example);
    }
}
