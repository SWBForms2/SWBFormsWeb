<%-- 
    Document   : users.jsp
    Created on : 22-jul-2018, 23:15:13
    Author     : javiersolis
--%>
<%@page import="org.semanticwb.datamanager.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    DataObject user=new DataObject();
    user.addParam("username", "autologin");
    user.addParam("email", "autologin@test.com");
    user.addParam("fullname", "Autologin");
    DataList roles=new DataList();
    user.addParam("roles", roles);
    roles.add("prog");
    roles.add("user");
    roles.add("admin");
    session.setAttribute("_USER_", user);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Autologin</title>
    </head>
    <body>
        <h1>Autologin...</h1>
    </body>
</html>
