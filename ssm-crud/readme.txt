查询：
    1.访问index.jsp页面
    *2.index.jsp页面通过<jsp:forward>发送出查询员工列表的请求
    3.EmployeeController来接受请求，查出员工数据
    4.来到list.jsp页面进行展示

查询-ajax
    1.index.jsp页面直接发送ajax请求进行员工分页数据的查询
    2.服务器将查出的数据，以json字符串的形式返回给浏览器
    3.浏览器收到js字符串。可以使用js进行解析，使用js通过dom增删改改变页面
    4.返回json。实现客服端的无关性。

新增-逻辑
    1.在index.jsp页面点击“新增”
    2.弹出新增对话框
    3.去数据库查询部门列表，显示在对话框中
    4.用户输入数据并进行校验
        4.1 jquery前端校验，ajax用户名重复校验。
        4.2 重要的数据都应该后端校验（JSR303）,唯一约束
    5.完成保存

REST风格的URI:
    1./emp/{id}   GET     :查询员工
    2./emp        POST    :保存插入员工
    3./emp/{id}   PUT     :修改员工
    4./emp/{id}   DELETE  :删除员工


修改-逻辑
    1.点击编辑
    2.弹出用户修改的模态框（显示用户信息）
    3.点击更新，完成用户修改

删除-逻辑
    1.单个删除
        URI：/emp/{id}   delete