<%-- 
    Document   : adm_sc_head
    Created on : 05-nov-2019, 16:38:52
    Author     : javiersolis
--%><%@page contentType="text/html" pageEncoding="UTF-8"%><%
    {
        boolean _debug=false;
        String _version="?ver=12.0";
        String _mode=_debug?"modules-debug":"modules";
        String _gz=_debug?"":".gz";
%>
        <script src="<%=contextPath%>/platform/js/eng.min.js?id=<%=eng.getId()%>" type="text/javascript"></script>           
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_Core.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_Foundation.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_Containers.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_Grids.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_Forms.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_DataBinding.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_RichTextEditor.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/system/<%=_mode%>/ISC_Calendar.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/skins/Tahoe/load_skin.js<%=_gz%><%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/isomorphic/locales/frameworkMessages_es.properties<%=_version%>" type="text/javascript"></script>
        <script src="<%=contextPath%>/platform/plupload/js/plupload.full.min.js" type="text/javascript"></script>                
        <link href="<%=contextPath%>/admin/css/sc_admin.css" rel="stylesheet" type="text/css" />
<%
    }
%>
