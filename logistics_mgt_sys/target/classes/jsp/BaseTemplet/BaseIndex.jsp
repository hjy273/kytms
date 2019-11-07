<%--
  Created by IntelliJ IDEA.
  User: nidaye
  Date: 2017/3/10
  Time: 9:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html>

<html>
<head>
    <base href="<%=basePath%>">
    <meta name="viewport" content="width=device-width"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>区域信息</title>
    <!--框架必需start-->
    <script src="/Content/scripts/jquery/jquery-1.10.2.min.js"></script>
    <link href="/Content/styles/font-awesome.min.css" rel="stylesheet"/>
    <link href="/Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet"/>
    <script src="/Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!--框架必需end-->
    <!--bootstrap组件start-->
    <link href="/Content/scripts/bootstrap/bootstrap.min.css" rel="stylesheet"/>
    <script src="/Content/scripts/bootstrap/bootstrap.min.js"></script>
    <script src="/Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="/Content/scripts/plugins/datepicker/WdatePicker.js"></script>
    <link href="/Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet"/>
    <link href="/Content/scripts/plugins/datetime/pikaday.css" rel="stylesheet"/>
    <link href="/Content/styles/jet-ui.css" rel="stylesheet"/>
    <script src="/Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="/Content/scripts/plugins/jqgrid/jqgrid.js"></script>
    <script src="/Content/scripts/plugins/tree/tree.js"></script>
    <script src="/Content/scripts/plugins/validator/validator.js"></script>
    <script src="/Content/scripts/plugins/datepicker/DatePicker.js"></script>
    <script src="/Content/scripts/utils/jet-ui.js"></script>
    <script src="/Content/scripts/utils/jet-form.js"></script>
    <style>
        body {
            margin: 10px;
            margin-bottom: 0px;
        }
    </style>
</head>
<body>

<script>
    $(function () {
        InitialPage();
        GetGrid();
    });
    //初始化页面
    function InitialPage() {
        //resize重设(表格、树形)宽高
        $(window).resize(function (e) {
            window.setTimeout(function () {
                $('#gridTable').setGridWidth(($('.gridPanel').width()));
                $("#gridTable").setGridHeight($(window).height() - 136.5);
            }, 200);
            e.stopPropagation();
        });
    }
    //加载表格
    function GetGrid() {
        var selectedRowIndex = 0;
        var $gridTable = $('#gridTable');
        $gridTable.jqGrid({
            url: "/zone/getList.action",
            datatype: "json",
            height: $(window).height() - 136.5,
            autowidth: true,
            colModel: [
                {label: '主键', name: 'id', hidden: true},
                {label: '区域名称', name: 'name', width: 230, align: 'center'},
                {label: '区域代码', name: 'code', width: 230, align: 'center'},
                {
                    label: "状态", name: "status", width: 70, align: "center",
                    formatter: function (cellvalue, options, rowObject) {
                        return top.clientdataItem.sys_common_status['' + cellvalue + '']
                    }
                },
                {label: "备注", name: "description", width: 140, align: "center"}
            ],
            viewrecords: true,
            rowNum: 30,
            rowList: [30, 50, 100],
            pager: "#gridPager",
            rownumbers: true,
            shrinkToFit: false,
            gridview: true,
            multiselect: true,//复选框
            multiboxonly: true,
            onSelectRow: function () {
                selectedRowIndex = $("#" + this.id).getGridParam('selrow');
            },
            gridComplete: function () {
                $("#" + this.id).setSelection(selectedRowIndex, false);
            }
        });
        //$gridTable.authorizeColModel()
        //初始化查询条件
        var colmodel = $('#gridTable').jqGrid('getGridParam', 'colModel');
        var ment = $("#queryLi");
        for (i = 0; i < colmodel.length; i++) {
            var s = colmodel[i];
            if (s.label) {
                ment.append("<li><a data-value='" + s.name + "'>" + s.label + "</a></li>");
            }
        }
        $("#queryCondition .dropdown-menu li").click(function () {
            var text = $(this).find('a').html();
            var value = $(this).find('a').attr('data-value');
            $("#queryCondition .dropdown-text").html(text).attr('data-value', value)
        });
        //查询事件
        $("#btn_Search").click(function () {
            var whereName = $("#queryCondition").find('.dropdown-text').attr('data-value');
            var whereValue = $("#txt_Keyword").val();
            $gridTable.jqGrid('setGridParam', {
                postData: {whereName: whereName, whereValue: whereValue}, page: 1
            }).trigger('reloadGrid');
        });
        //查询回车
        $('#txt_Keyword').bind('keypress', function (event) {
            if (event.keyCode == "13") {
                $('#btn_Search').trigger("click");
            }
        });
    }
    //新增
    function btn_add() {
        dialogOpen({
            id: "Form",
            title: '区域信息',
            url: 'jsp/Zone/Form.jsp',
            width: "750px",
            height: "250px",
            callBack: function (iframeId) {
                top.frames[iframeId].AcceptClick();
            }
        });
    }
    ;
    //编辑
    function btn_edit() {
        var keyValue = $("#gridTable").jqGridRowValue("id");
        if (checkedRow(keyValue)) {
            dialogOpen({
                id: "Form",
                title: '区域信息',
                url: 'jsp/Zone/Form.jsp?keyValue=' + keyValue,
                width: "750px",
                height: "250px",
                callBack: function (iframeId) {
                    top.frames[iframeId].AcceptClick();
                }
            });
        }
    }
    //失效失效
    function btn_enabled(keyValue) {
        id = $("#gridTable").jqGridRowValue("id");
        if (id) {
            $.ConfirmAjax({
                msg: "注：你是否要改变状态？",
                url: "/zone/updataStatus.action",
                param: {id: id, status: keyValue},
                success: function (data) {
                    $("#gridTable").trigger("reloadGrid");
                    if (data.type) {
                        dialogMsg(data.obj, 1);
                    } else {
                        dialogAlert(data.obj, -1);
                    }
                }
            })
        }
    }
    function btn_export() {

    }
</script>
<div class="titlePanel">
    <div class="title-search">
        <table>
            <tr>
                <td>
                    <div id="queryCondition" class="btn-group">
                        <a class="btn btn-default dropdown-text" data-toggle="dropdown">选择条件</a>
                        <a class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span
                                class="caret"></span></a>
                        <ul id="queryLi" class="dropdown-menu">
                        </ul>
                    </div>
                </td>
                <td style="padding-left: 2px;">
                    <input id="txt_Keyword" type="text" class="form-control" placeholder="请输入要查询关键字"
                           style="width: 200px;"/>
                </td>
                <td style="padding-left: 5px;">
                    <a id="btn_Search" class="btn btn-primary"><i class="fa fa-search"></i>&nbsp;查询</a>
                </td>
            </tr>
        </table>
    </div>
    <div class="toolbar">
        <div class="btn-group">
            <a id="Zone-replace" class="btn btn-default" onclick="reload();"><i class="fa fa-refresh"></i>&nbsp;刷新</a>
            <a id="Zone-add" class="btn btn-default" onclick="btn_add()"><i class="fa fa-plus"></i>&nbsp;新增</a>
            <a id="Zone-edit" class="btn btn-default" onclick="btn_edit()"><i class="fa fa-pencil-square-o"></i>&nbsp;编辑</a>
            <a id="Zone-more" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                <i class="fa fa-reorder"></i>&nbsp;更多<span class="caret"></span>
            </a>
            <ul class="dropdown-menu pull-right">
                <li id="Zone-export"><a onclick="btn_export()"><i></i>&nbsp;导出Excel</a></li>
                <li id="Zone-enabled"><a onclick="btn_enabled('ACTIVE')"><i></i>&nbsp;生效</a></li>
                <li id="Zone-disabled"><a onclick="btn_enabled('UNACTIVE')"><i></i>&nbsp;失效</a></li>

            </ul>
        </div>
        <script>$('.toolbar').authorizeButton()</script>
    </div>
</div>
<div class="gridPanel">
    <table id="gridTable"></table>
    <div id="gridPager"></div>
</div>
</body>
</html>
