<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>首页</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <%
        pageContext.setAttribute("APP_PATH",request.getContextPath());
    %>
    <!-- Bootstrap -->
    <link href="${APP_PATH}/static/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- jQuery (Bootstrap 的所有 JavaScript 插件都依赖 jQuery，所以必须放在前边) -->
    <script src="${APP_PATH}/static/js/jquery-1.12.4.min.js"></script>
    <!-- 加载 Bootstrap 的所有 JavaScript 插件。你也可以根据需要只加载单个插件。 -->
    <script src="${APP_PATH}/static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>

    <style type="text/css">

    </style>

    <script type="text/javascript">

        $(function () {
            //总页的记录数
            var totalRecord,currentPage;

            //页面加载完成后，直接发送ajax请求，得到json数据
            //一进来就去首页
            to_page(1);

            //发送ajax请求到指定页面
            function to_page(pn) {
                $.ajax({
                    url:"${APP_PATH}/emps",
                    data:"pn="+pn,
                    type:"GET",
                    dataType:"json",
                    success:function (result) {
                        //alert(result);
                        //1.解析并显示员工数据
                        build_emps_table(result);
                        //2.解析并显示分页信息
                        build_page_info(result);
                        //3.解析显示分页条数据
                        build_page_nav(result);

                        //重置"#check_all"多选框
                        var flag =$(".check_item:checked").length == $(".check_item").length;
                        $("#check_all").prop("checked",flag);
                    }
                })
            }



            //查出所有的部门信息并显示在下拉列表中
            function getDepts(ele) {
                $.ajax({
                    url:"${APP_PATH}/depts",
                    type: "GET",
                    success:function (result) {
                        //{"code":100,"msg":"处理成功",
                        // "extend":{"depts":[{"deptId":1,"deptName":"开发部"},{"deptId":2,"deptName":"测试部"}]}}
                        //显示部门信息在下拉列表中
                        //清空下拉列表
                        $(ele).empty();
                        $.each(result.extend.depts,function (index,item) {
                            var optionEle =$("<option></option>").append(item.deptName).attr("value",item.deptId);
                            optionEle.appendTo($(ele));
                        })
                    }
                })
            }

            //完整的重置表单
            function reset_form(ele){
                //重置表单内容
                $(ele)[0].reset();
                //清空表单的样式
                //*：表示匹配所有元素
                $(ele).find("*").removeClass("has-success has-error");
                $(ele).find(".help-block").text("");

            }

            //点击新增按钮弹出模态框
            $("#emp_add_modal").click(function () {
                //清除表单数据，表单重置(应该所有的样式也重置)
                reset_form("#empAddModal form");
                //发送ajax请求，查出部门信息，显示在下拉列表中
                getDepts("#dept_add_select");
                //弹出模态框
                $("#empAddModal").modal({
                    backdrop:"static"
                });
            });

            //抽取显示校验成功失败信息
            function show_validate_msg(ele,status,msg) {
                $(ele).parent().removeClass("has-success has-error");
                $(ele).next("span").text("");
                if("success"==status){
                    $(ele).parent().addClass("has-success");
                    $(ele).next("span").text(msg);
                }else if("error"==status){
                    $(ele).parent().addClass("has-error");
                    $(ele).next("span").text(msg);
                }
            }

            //校验表单数据
            function validate_add_form(){
                //1.拿到要校验的数据，采用正则表达式
                var empName = $("#empName_add_input").val();
                //可以允许中文
                var regName =/(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5}$)/;
                if(!regName.test(empName)){
                    //alert("用户名可以是2-5位中文或者6-16位英文和数字的组合");
                    //显示之前要清空样式
                    show_validate_msg("#empName_add_input","error","用户名可以是2-5位中文或者6-16位英文和数字的组合");
                    return false;
                }else{
                    show_validate_msg("#empName_add_input","success","");
                }
                //2.校验邮箱的数据
                var email = $("#email_add_input").val();
                var regEmail =/^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
                if(!regEmail.test(email)){
                    //alert("邮箱格式不正确");
                    show_validate_msg("#email_add_input","error","邮箱格式不正确");
                    return false;
                }else{
                    show_validate_msg("#email_add_input","success","");
                }
                return true;

            };

            //给员工姓名输入框绑定一个change事件，发送ajax请求给服务器
            $("#empName_add_input").change(function () {
                //发送ajax请求校验用户名是否可用
                var empName =$(this).val();
                $.ajax({
                    url:"${APP_PATH}/checkUser",
                    data:"empName="+empName,
                    type:"POST",
                    success:function (result) {
                        if(result.code ==100){
                            show_validate_msg("#empName_add_input","success","用户名可用");
                            $("#emp_save_btn").attr("ajax-va","success");
                        }else {
                            show_validate_msg("#empName_add_input","error",result.extend.va_msg);
                            $("#emp_save_btn").attr("ajax-va","error");
                        }
                    }
                });
            });

            //点击保存插入数据
            $("#emp_save_btn").click(function () {
                //1.模态框中填写的表单数据提交给服务器
                //1.先对要提交给服务器的数据进行校验
                if(!validate_add_form()){
                    return false;
                }
                //1.判断之前的ajax用户名是否可用,通过给按钮添加属性attr来判断用户是否已存在
                if($(this).attr("ajax-va")=="error"){
                    return false;
                }
                //2.发送ajax请求保存员工
                //console.log($("#empAddModal form").serialize());
                $.ajax({
                    url:"${APP_PATH}/emp",
                    type:"POST",
                    data:$("#empAddModal form").serialize(),
                    success:function (result) {
                        //alert(result.msg);
                        if(result.code ==100){
                            //员工保存成功：
                            //1.关闭模态框
                            $('#empAddModal').modal("hide");
                            //2.来到最后一页，显示刚才保存的数据
                            //分页插件会把一个大于总页码的请求显示最后一页
                            //给一个大的数
                            to_page(totalRecord);
                        }else {
                            //显示失败信息
                            if(undefined !=result.extend.errorFields.email){
                                //显示邮箱错误信息
                                show_validate_msg("#email_add_input","error",result.extend.errorFields.email);
                            }
                            if(undefined !=result.extend.errorFields.empName){
                                //显示员工名字的错误信息
                                show_validate_msg("#empName_add_input","error",result.extend.errorFields.empName);
                            }
                        }

                    }
                });
            });




            //解析显示表格信息
            function build_emps_table(result) {
                //清空表格
                $("#emps_table tbody").empty();
                var emps =result.extend.pageInfo.list;
                $.each(emps,function (index,item) {
                    //显示在表格中
                    var checkBoxTd =$("<td><input type='checkbox' class='check_item'/></td>")
                    console.log(item.empId);
                    var empIdTd =$("<td></td>").append(item.empId);
                    var empNameTd = $("<td></td>").append(item.empName);
                    var genderTd = $("<td></td>").append(item.gender == 'M'?'男':'女');
                    var emailTd = $("<td></td>").append(item.email);
                    var deptNameTd=$("<td></td>").append(item.department.deptName);
                    /*<button class="btn btn-primary btn-sm">
                        <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>
                    编辑
                    </button>*/
                    var editBtn_span =$("<span></span>").addClass("glyphicon glyphicon-pencil")
                        .attr("aria-hidden","true");
                    var deleteBtn_span =$("<span></span>").addClass("glyphicon glyphicon-trash")
                        .attr("aria-hidden","true");
                    var editBtn =$("<button></button>").addClass("btn btn-primary btn-sm edit_btn")
                        .append(editBtn_span).append("编辑");
                    //为编辑按钮添加一个自定义的属性，表示当前员工的id
                    editBtn.attr("edit-id",item.empId);
                    var deleteBtn = $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
                        .append(deleteBtn_span).append("删除");
                    //为删除按钮添加员工自定义的属性来表示当前要删除的员工id
                    deleteBtn.attr("del_id",item.empId);
                    //append方法执行完成后还是返回原来的元素
                    $("<tr></tr>").append(checkBoxTd)
                        .append(empIdTd).append(empNameTd).append(genderTd)
                        .append(emailTd).append(deptNameTd)
                        .append($("<td></td>").append(editBtn).append(deleteBtn))
                        .appendTo("#emps_table tbody");
                })
            }

            //解析显示分页信息的
            function build_page_info(result) {
                //清空分页信息
                $("#page_info_area").empty();
                var page_info=result.extend.pageInfo;
                $("#page_info_area").append("当前"+page_info.pageNum+"页，" +
                    "总"+page_info.pages+"页，总"+page_info.total+"记录");
                totalRecord=page_info.total;
                currentPage = page_info.pageNum;
            }

            //解析显示分页条的,点击分页要能去下一页等动作
            function build_page_nav(result) {
                //page_nav_area
                //清空分页导航条
                $("#page_nav_area").empty();
                var ul =$("<ul></ul>").addClass("pagination");

                //构建元素
                var firstPageLi = $("<li></li>").append($("<a></a>").append("首页").attr("href","#"));
                var prePageLi =$("<li></li>").append($("<a></a>").append("&laquo;"));

                //当没有前一页时添加class不能被点击
                if(result.extend.pageInfo.hasPreviousPage == false){
                    firstPageLi.addClass("disabled");
                    prePageLi.addClass("disabled");
                }else {
                    //为元素添加点击事件
                    firstPageLi.click(function () {
                        to_page(1);
                    })
                    prePageLi.click(function () {
                        to_page(result.extend.pageInfo.pageNum-1);
                    })
                }
                //添加首页和前一页
                ul.append(firstPageLi).append(prePageLi);

                //构建元素
                var nextPageLi=$("<li></li>").append($("<a></a>").append("&raquo;"));
                var lastPageLi = $("<li></li>").append($("<a></a>").append("末页").attr("href","#"));
                if(result.extend.pageInfo.hasNextPage ==false){
                    //禁用的话就不用绑定点击事件了
                    nextPageLi.addClass("disabled");
                    lastPageLi.addClass("disabled");
                }else{
                    //给下一页和末页添加点击事件
                    nextPageLi.click(function () {
                        to_page(result.extend.pageInfo.pageNum +1);
                    });
                    lastPageLi.click(function () {
                        to_page(result.extend.pageInfo.pages);
                    })
                }

                $.each(result.extend.pageInfo.navigatepageNums,function (index,item) {
                    var numLi =$("<li></li>").append($("<a></a>").append(item));
                    //给正在显示的分页添加高亮
                    if(result.extend.pageInfo.pageNum == item){
                        numLi.addClass("active");
                    }
                    //点击li时发送ajax请求
                    numLi.click(function () {
                        to_page(item);
                    });
                    ul.append(numLi);
                });
                //添加下一页和末页的提示
                ul.append(nextPageLi).append(lastPageLi);
                //把ul添加到nav导航条中
                var navEle =$("<nav></nav>").append(ul);
                navEle.appendTo("#page_nav_area");
            }




            //按钮创建之前就绑定了click,所以绑不上
            //1.可以在创建按钮的时候就绑定。2.live()方法，可为后来添加的元素也添加方法
            //jQuery新版没有此方法。   我们可以用on方法绑定事件
            $(document).on("click",".edit_btn",function () {
                //this 还是edit_btn
                //0.查出员工信息，显示员工信息
                getEmp($(this).attr("edit-id"));
                //1.查出部门信息，并显示部门列表
                getDepts("#empUpdateModal select");

                //2.把员工的id传递给模态框的更新按钮
                $("#emp_update_btn").attr("edit-id",$(this).attr("edit-id"));

                //3.弹出模态框
                $("#empUpdateModal").modal({
                    backdrop:"static"
                });
            })

            //获取员工显示信息
            function getEmp(id) {
                $.ajax({
                    url:"${APP_PATH}/emp/"+id,
                    type:"GET",
                    success:function (result) {
                        //console.log(result);
                        var empData = result.extend.emp;
                        $("#empName_update_static").text(empData.empName);
                        $("#email_update_input").val(empData.email);
                        $("#empUpdateModal input[name='gender']").val([empData.gender]);
                        $("#empUpdateModal select").val([empData.dId]);
                    }
                })
            }

            //点击更新，更新员工信息
            $("#emp_update_btn").click(function () {
                //1.验证邮箱是否合法
                var email = $("#email_update_input").val();
                var regEmail =/^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
                if(!regEmail.test(email)){
                    //alert("邮箱格式不正确");
                    show_validate_msg("#email_update_input","error","邮箱格式不正确");
                    return false;
                }else{
                    show_validate_msg("#email_update_input","success","");
                }

                //alert($("#empUpdateModal form").serialize());
                //2.发送ajax请求，保存更新的员工数据
                $.ajax({
                    url:"${APP_PATH}/emp/"+$(this).attr("edit-id"),
                    type:"PUT",
                    data:$("#empUpdateModal form").serialize(),
                    success:function (result) {
                        //alert(result.msg);
                        //1.关闭模态对话框
                        $("#empUpdateModal").modal("hide");
                        //2.回到本页面
                        to_page(currentPage);
                    }
                });
            });





            //点击删除，单个删除
            $(document).on("click",".delete_btn",function () {
                //1.弹出是否确认删除对话框
                var empName = $(this).parents("tr").find("td:eq(2)").text();
                var empId = $(this).attr("del_id");
                if(confirm("确认要删除【"+empName+"】吗？")){
                    //确认，发送ajax请求删除即可
                    $.ajax({
                        url:"${APP_PATH}/emp/"+empId,
                        type:"DELETE",
                        success:function (result) {
                            alert(result.msg);
                            //回到本页
                            to_page(currentPage);
                        }

                    });
                }
            });

            //完成全选全不选
            $("#check_all").click(function () {
                //attr()获取checked是undefined
                //我们这些DOM原生的属性，使用prop()来获取
                //prop()获取dom原生属性的值
                //$(this).prop("checked");
                $(".check_item").prop("checked",$(this).prop("checked"));
            });

            //为 .check_item 也绑定单击事件
            $(document).on("click",".check_item",function () {
                //判断当前选中的元素是否是5个
                var flag =$(".check_item:checked").length == $(".check_item").length;
                $("#check_all").prop("checked",flag);
            });

            //点击全部删除，就批量删除
            $("#emp_delete_all_btn").click(function () {
                var empName ="";
                var del_idstr="";
                $.each($(".check_item:checked"),function (index,item) {
                    //alert($(item).parents("tr").find("td:eq(2)").text());
                    empName +=$(item).parents("tr").find("td:eq(2)").text()+",";

                    //组装员工Id的字符串
                    del_idstr +=$(item).parents("tr").find("td:eq(1)").text()+"-";
                });
                //去除多余的“-”
                empName = empName.substring(0,empName.length-1);
                //去除员工id多余的“-”
                del_idstr = del_idstr.substring(0,del_idstr.length-1);

                if(confirm("确认删除【"+empName+"】吗？")){
                    //发送ajax请求删除
                    $.ajax({
                        url:"${APP_PATH}/emp/"+del_idstr,
                        type:"DELETE",
                        success:function (result) {
                            alert(result.msg);
                            //回到当前页面
                            to_page(currentPage);
                        }
                    });
                }
            });

        })
    </script>

</head>
<body>

<%--务必将模态框的 HTML 代码放在文档的最高层级内（也就是说，尽量作为 body 标签的直接子元素），
以避免其他组件影响模态框的展现和/或功能。--%>

<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">员工修改</h4>
            </div>
            <div class="modal-body">
                <%--水平排列的表单--%>
                <form class="form-horizontal">
                    <div class="form-group">
                        <%--label for属性指定哪个输入框的id--%>
                        <label for="empName_add_input" class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <p class="form-control-static" id="empName_update_static"></p>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_update_input" placeholder="email@atguigu.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_update_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_update_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-4">
                            <%--部门提交部门id即可--%>
                            <select class="form-control" name="dId">
                                <%--不要把下拉项写死，通过数据库中查出来--%>

                            </select>
                        </div>
                    </div>
                </form>
            </div><%--modal-body--%>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_update_btn">更新</button>
            </div>
        </div>
    </div>
</div>


<!-- 员工添加的模态框 -->
<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">员工添加</h4>
            </div>
            <div class="modal-body">
                <%--水平排列的表单--%>
                <form class="form-horizontal">
                    <div class="form-group">
                        <%--label for属性指定哪个输入框的id--%>
                        <label for="empName_add_input" class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <input type="text" name="empName" class="form-control" id="empName_add_input" placeholder="empName">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_add_input" placeholder="email@atguigu.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-4">
                            <%--部门提交部门id即可--%>
                            <select class="form-control" name="dId" id="dept_add_select">
                                <%--不要把下拉项写死，通过数据库中查出来--%>
                                
                            </select>
                        </div>
                    </div>
                </form>
            </div><%--modal-body--%>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_save_btn">保存</button>
            </div>
        </div>
    </div>
</div>

<%--使用bootstrap搭建页面--%>
<div class="container">
    <%--标题行--%>
    <div class="row">
        <div class="col-md-12">
            <h1>SSM-CRUD</h1>
        </div>
    </div>
    <%--按钮--%>
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="emp_add_modal">新增</button>
            <button class="btn btn-danger" id="emp_delete_all_btn">删除</button>
        </div>
    </div>
    <%--显示表格数据--%>
    <div class="row">
        <div class="col-md-12">
            <table class="table table-hover" id="emps_table">
                <thead>
                    <tr>
                        <th>
                            <input type="checkbox" id="check_all"/>
                        </th>
                        <th>#</th>
                        <th>empName</th>
                        <th>gender</th>
                        <th>email</th>
                        <th>deptName</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>

                </tbody>

            </table>
        </div>
    </div>

    <%--显示分页信息--%>
    <div class="row">
        <%--分页文字信息--%>
        <div class="col-md-6" id="page_info_area">

        </div>
        <%--分页条信息--%>
        <div class="col-md-6" id="page_nav_area">

        </div>

    </div>

</div>

</body>
</html>