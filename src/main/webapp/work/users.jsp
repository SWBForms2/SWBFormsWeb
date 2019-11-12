<%-- 
    Document   : users
    Created on : 07-nov-2019, 15:45:15
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String contextPath = request.getContextPath();
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/datasources.js", session);
    DataObject user=eng.getUser();    
    String id=request.getParameter("id");
    if(id==null)
    {
%>
<div>
   Alta de usuario
</div>
<%       
        return;
    }
    DataObject obj=eng.getDataSource("User").getObjectByNumId(id);
    if(obj==null)
    {
        response.sendError(404);
        return;
    }
    eng.getDataSource("voc_tipo_atencion").fetchObjByProp("id", obj.getString("tipo_atencion_id"),DataObject.EMPTY);
    //obj.getDateFormated(key, format)
%>
<div>
    Usuario: <b><%=obj.getString("fullname")%></b><br>    
    <font size="-1">email: <%=obj.getString("email")%></font>
</div>
