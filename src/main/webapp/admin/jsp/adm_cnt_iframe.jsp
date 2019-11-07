<%-- 
    Document   : sc_grid_detail
    Created on : 23-oct-2019, 18:37:30
    Author     : javiersolis
--%>
<%@page import="org.semanticwb.datamanager.script.ScriptObject"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.io.IOException"%>
<%@page import="org.semanticwb.datamanager.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    
    String getParams(DataList<String> paths)
    {
        StringBuilder ret=new StringBuilder();
        ret.append("p=");
        Iterator<String> it=paths.iterator();
        while (it.hasNext()) {
            String n = it.next();
            ret.append(n);
            if(it.hasNext())ret.append("/");
        }
        return ret.toString();
    }    
    
    DataList<String> getContentPaths(String params[], String id)
    {
        //Split path
        DataList<String> paths=new DataList();
        String ps[]=params;
        for(String p:ps)
        {
            for(String p2:p.split("/"))
            {
                paths.add(p2);
            }
        }   
        if(id!=null && id.length()>0)
        {
            if(paths.size()>0)
            {
                String last=paths.remove(paths.size()-1);
                if(id.lastIndexOf(":")>-1)
                {
                    last+=id.substring(id.lastIndexOf(":"));
                }else
                {
                    last+=":"+id;
                }
                paths.add(last);
            }
        }
        return paths;
    }
    
    String getPath(String type, DataList<String> paths)
    {
        String fname=type;        
        if("sc_grid".equals(type) 
          || "sc_form".equals(type)
          || "sc_grid_detail".equals(type)
          || "sc_fulltext_search_detail".equals(type)
          || "sc_search_detail".equals(type)
        )fname="sc_grid";
        return "adm_cnt_"+fname+"?"+getParams(paths);        
    }
    
%><%
    String contextPath = request.getContextPath();
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user=eng.getUser();
    
    String a=request.getParameter("a");    
    
    DataList<String> paths=getContentPaths(request.getParameterValues("p"), request.getParameter("id"));
    String p=getParams(paths);

    String pl=paths.get(paths.size()-1);    
    String pid=pl;
    String id=null;
    int i=pid.indexOf(":");
    if(i>-1)
    {
        id=pid.substring(i+1);
        pid=pid.substring(0,i);
    }   
    
    DataObject obj=eng.getDataSource("Page").getObjectByNumId(pid);   
    String type=obj.getString("type"); 
    String _path=obj.getString("path","");
    
    if(!type.equals("iframe_content"))
    {
        _path=getPath(type, paths);
    }
    
    String _links="";
    
    //Valida parametros de ligado si el tab es de tipo forma
    if(type.equals("sc_form") && id==null && paths.size()>1)
    {        
        String pid2=paths.get(paths.size()-2);
        String id2=null;
        int i2=pid2.indexOf(":");
        if(i2>-1)
        {
            id2=pid2.substring(i2+1);
            pid2=pid2.substring(0,i2);
        } 

        DataObject obj2=eng.getDataSource("Page").getObjectByNumId(pid2);
        if(obj2!=null && obj2.getString("ds").equals(obj.getString("ds")))
        {
            _links="&id="+id2;
        }
    }     

%>
        <iframe class="ifram_content <%=pid%>" src="<%=_path%><%=_links%><%=(a!=null?"&a="+a:"")%>" frameborder="0" width="100%"></iframe>
        <script type="text/javascript">
            $(window).resize();
        </script>        