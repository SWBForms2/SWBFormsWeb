<%-- 
    Document   : uml
    Created on : 17-mar-2018, 17:45:33
    Author     : javiersolis
--%>
<%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!

%><%
    String contextPath = request.getContextPath();
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    boolean iframe = request.getParameter("iframe") != null;
    //System.out.println(obj);
    String _title = "Data Dictionary";
    String _smallName = "";
    String _fileName = contextPath + "/admin/jsp/data_dict.jsp";
    //if(!eng.hasUserAnyRole(obj.getDataList("roles_view")))response.sendError(403,"Acceso Restringido...");

    StringBuilder data = new StringBuilder();
    StringBuilder rel = new StringBuilder();
    if (iframe) {
        DataObjectIterator it = eng.getDataSource("DataSource").find();
        while (it.hasNext()) {
            DataObject obj = it.next();
            if (!obj.getBoolean("backend") && !obj.getBoolean("frontend")) {
                continue;
            }
            data.append("[");
            data.append(obj.getString("id"));
            data.append("|");

            DataObject query = new DataObject();
            query.addSubList("sortBy").add("order");
            query.addSubObject("data").addParam("ds", obj.getId());
            DataObjectIterator it2 = eng.getDataSource("DataSourceFields").find(query);
            //System.out.println("size:"+it2.size()+":"+it2.total());
            while (it2.hasNext()) {
                DataObject fobj = it2.next();
                boolean req = fobj.getBoolean("required");
                String name = fobj.getString("name");
                String type = fobj.getString("type");
                String dataSource = null;
                String valueField = null;
                boolean multiple = false;

                if (req) {
                    data.append("*");
                }
                data.append(name);

                query = new DataObject();
                query.addSubObject("data").addParam("dsfield", fobj.getId());
                DataObjectIterator it3 = eng.getDataSource("DataSourceFieldsExt").find(query);
                while (it3.hasNext()) {
                    DataObject feobj = it3.next();
                    String att = feobj.getString("att");
                    String value = feobj.getString("value");

                    if (att.equals("stype")) {
                        type += "(" + value + ")";
                    }
                    if (att.equals("dataSource")) {
                        dataSource = value;
                        //if(valueField==null)valueField="_id";
                    }
                    if (att.equals("valueField")) {
                        valueField = value;
                    }
                    if (att.equals("multiple")) {
                        multiple = Boolean.parseBoolean(value);
                    }
                }

                if (dataSource != null) {
                    data.append(":" + dataSource + (valueField != null ? "." + valueField : ""));
                    rel.append("[" + dataSource + "]");
                    if (multiple) {
                        //data.append("(0..*)");
                        rel.append("*");
                    }
                    rel.append("<-");
                    rel.append("[" + obj.getString("id") + "]");
                    rel.append("\\n");
                } else if (type != null) {
                    data.append(": " + type);
                }
                if (it2.hasNext()) {
                    data.append(";");
                }
            }

            data.append("]\\n");
        }
        data.append(rel);
    }

    //********************************** Ajax Content ************************************************************
    if (!iframe) {
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small><%=_smallName%></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Programming</li>
        <li class="active"><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
    </ol>
</section>
<!-- Main content -->
<section id="content" style="padding: 7px">  
    <iframe class="ifram_content" src="<%=_fileName%>?iframe=true" frameborder="0" width="100%"></iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>            
</section>
<!-- /.content -->
<%
    //********************************** End Ajax ************************************************************
} else {
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Data Dictionary</title>
        <style>
            body{
                background-color: white;
            }
            table.DataSource {
                font-family: Arial, Helvetica, sans-serif;
                border: 1px solid #1C6EA4;
                background-color: #EEEEEE;
                width: 100%;
                text-align: left;
                border-collapse: collapse;
            }
            table.DataSource td, table.DataSource th {
                border: 1px solid #AAAAAA;
                padding: 3px 2px;
            }
            table.DataSource tbody td {
                font-size: 12px;
            }
            table.DataSource tr:nth-child(even) {
                background: #D0E4F5;
            }
            table.DataSource thead {
                background: #1C6EA4;
                border-bottom: 2px solid #444444;
            }
            table.DataSource thead th {
                font-size: 15px;
                font-weight: bold;
                color: #FFFFFF;
                border-left: 2px solid #D0E4F5;
            }
            table.DataSource thead th:first-child {
                border-left: none;
            }
            
            
            table.DataFields {
                font-family: Arial, Helvetica, sans-serif;
                border: 1px solid #1C6EA4;
                background-color: #EEEEEE;
                width: 100%;
                text-align: left;
                border-collapse: collapse;
            }
            table.DataFields td, table.DataFields th {
                border: 1px solid #AAAAAA;
                padding: 2px 2px;
            }
            table.DataFields tbody td {
                font-size: 11px;
            }
            table.DataFields tr:nth-child(even) {
                background: #D0E4F5;
            }
            table.DataFields thead {
                background: #2C7EB4;
                border-bottom: 2px solid #444444;
            }
            table.DataFields thead th {
                font-size: 12px;
                font-weight: bold;
                color: #FFFFFF;
                border-left: 2px solid #D0E4F5;
            }
            table.DataFields thead th:first-child {
                border-left: none;
            }       
        </style>
    </head>
    <body>
<%        
        DataObject query = new DataObject();
        query.addSubList("sortBy").add("id");    
        DataObjectIterator it = eng.getDataSource("DataSource").find(query);
        while (it.hasNext()) {
            DataObject obj = it.next();
            if (!obj.getBoolean("backend") && !obj.getBoolean("frontend")) {
                continue;
            }
%>
        <table class="DataSource">
            <thead>
                <tr><th colspan="2"><%=obj.getString("id")%></th></tr>                
            </thead>
            <tbody>
                <tr><td width="150">Class:</td><td><%=obj.getString("scls","")%></td></tr>
                <tr><td width="150">Description:</td><td><%=obj.getString("description","")%></td></tr>
                <tr><td width="150">Squema:</td><td><%=obj.getString("modelid",""+eng.eval("_modelid"))%></td></tr>
                <tr><td width="150">Store:</td><td><%=obj.getString("dataStore",""+eng.eval("_dataStore"))%></td></tr>
                <tr><td width="150">Display Field:</td><td><%=obj.getString("displayField","")%></td></tr>
                <%if(obj.getString("roles_fetch")!=null){%><tr><td width="150">Fetch Roles:</td><td><%=obj.getString("roles_fetch","")%></td></tr><%}%>
                <%if(obj.getString("roles_add")!=null){%><tr><td width="150">Add Roles:</td><td><%=obj.getString("roles_add","")%></td></tr><%}%>
                <%if(obj.getString("roles_update")!=null){%><tr><td width="150">Update Roles:</td><td><%=obj.getString("roles_update","")%></td></tr><%}%>
                <%if(obj.getString("roles_remove")!=null){%><tr><td width="150">Remove Roles:</td><td><%=obj.getString("roles_remove","")%></td></tr><%}%>
            </tbody>            
        </table>    
        <table class="DataFields">
            <thead>               
                <tr>
                    <th>Prop</th>
                    <th>Title</th>
                    <th>Type</th>
                    <th>Ref</th>
                    <th>Length</th>
                    <th>Req</th>
                    <th>Example</th>
                    <th>Order</th>
                    <th>Description</th>
                    <th>Validate</th>
                </tr>
            </thead>                  
            <tbody>                
<%            
            query.addSubList("sortBy").add("order");
            query.addSubObject("data").addParam("ds", obj.getId());
            DataObjectIterator it2 = eng.getDataSource("DataSourceFields").find(query);
            while (it2.hasNext()) {
                DataObject fobj = it2.next();
                boolean req = fobj.getBoolean("required");
                String name = fobj.getString("name");
                String title = fobj.getString("title");
                String type = fobj.getString("type","");
                String length = fobj.getString("length","");
                String example = fobj.getString("example","");
                String order = fobj.getString("order","");
                String description = fobj.getString("description","");
                String dataSource = "";
                String valueField = null;
                boolean multiple = false;
                String validators = "";
                String stype = null;

                query = new DataObject();
                query.addSubObject("data").addParam("dsfield", fobj.getId());
                DataObjectIterator it3 = eng.getDataSource("DataSourceFieldsExt").find(query);
                while (it3.hasNext()) {
                    DataObject feobj = it3.next();
                    String att = feobj.getString("att");
                    String value = feobj.getString("value");

                    if (att.equals("stype")) {
                        stype = value;
                    }
                    if (att.equals("dataSource")) {
                        dataSource = value;
                    }
                    if (att.equals("valueField")) {
                        valueField = value;
                    }
                    if (att.equals("multiple")) {
                        multiple = Boolean.parseBoolean(value);
                    }
                    
                    if (att.equals("validators")) {
                        validators = value;
                    }                    
                }
%>
                <tr>
                    <td><%=name%></td>
                    <td><%=title%></td>
                    <td><%=type+(stype!=null?"("+stype+")":"")%></td>
                    <td><%=dataSource+(valueField!=null?"."+valueField:"")%></td>
                    <td><%=length%></td>
                    <td><%=req%></td>
                    <td><%=example%></td>
                    <td><%=order%></td>
                    <td><%=description%></td>
                    <td><%=validators%></td>
<%                
            }
%>
            </tbody>
        </table>  
        <br>
<%
        }        
%>        
    </body>
</html>
<%
    }
%>