<%-- 
    Document   : admin_content.jsp
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="java.util.*"%><%@page import="java.net.*"%><%@page import="java.io.IOException"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    
    String getPageLink(DataObject base, boolean active, boolean link)
    {
        //System.out.println("page:"+page.getId()+"->"+active+"->"+link);
        DataObject page=base;
        StringBuilder ret=new StringBuilder();
        String title=page.getString("name","");
        String path=page.getString("path");
        String type=page.getString("type");
        
        if("head".equals(type))
        {
            //
        }else if("group_menu".equals(type))
        {
            ret.append("<li"+(active?" class=\"active\"":"")+">");
            ret.append(title);
            ret.append("</li>");      
        }else if("url_content".equals(type))
        {
            ret.append("<li"+(active?" class=\"active\"":"")+">");
            if(link)if(path!=null)ret.append("<a href=\""+path+"\">");
            ret.append(title);
            if(link)if(path!=null)ret.append("</a>");
            ret.append("</li>");            
        }else if("ajax_content".equals(type))
        {
            ret.append("<li"+(active?" class=\"active\"":"")+">");
            if(link)if(path!=null)ret.append("<a href=\""+path+"\" data-history=\"#"+page.getNumId()+"\" data-target=\".content-wrapper\" data-load=\"ajax\">");
            ret.append(title);
            if(link)if(path!=null)ret.append("</a>");
            ret.append("</li>");            
        }else 
        {
            ret.append("<li"+(active?" class=\"active\"":"")+">");
            if(link)ret.append("<a href=\"admin_content?p="+page.getNumId()+"\" data-history=\"#"+page.getNumId()+"\" data-target=\".content-wrapper\" data-load=\"ajax\">");
            ret.append(title);
            if(link)ret.append("</a>");
            ret.append("</li>");            
        }
        return ret.toString();
    }
    
    String getParentPath(DataObject page, SWBScriptEngine eng) throws IOException
    {
        StringBuilder ret=new StringBuilder();
        String parentId=page.getString("parentId");
        if(parentId!=null)
        {
            DataObject obj=eng.getDataSource("Page").getObjectById(parentId);   
            ret.append(getParentPath(obj,eng));
            ret.append(getPageLink(obj,false,true));
        }
        return ret.toString();
    } 
   
    
    String getPagePath(SWBScriptEngine eng, HttpServletRequest request, DataList<String> paths, DataList<String> helpBoxes) throws IOException
    {
        StringBuilder ret=new StringBuilder();
        for(int x=0;x<paths.size();x++)
        {
            boolean last=(x==(paths.size()-1));
            boolean first=(x==0);
            
            String p=paths.get(x);            
            String pid=p;
            String id=null;
            
            int i=pid.indexOf(":");
            if(i>-1)
            {
                id=pid.substring(i+1);
                pid=pid.substring(0,i);
            }    
                        
            DataObject obj=eng.getDataSource("Page").getObjectByNumId(pid);   
            if(first)
            {
                ret.append(getParentPath(obj,eng));
            }

            if(first)
            {
                ret.append(getPageLink(obj,last && id==null,true));                    
            }else
            {
                ret.append("<li>");
                ret.append("<a href=\"admin_content?"+getParams(paths, x)+"&t=tab_"+obj.getNumId()+"\" data-history=\"#"+obj.getNumId()+"\" data-target=\".content-wrapper\" data-load=\"ajax\">");
                ret.append(obj.getString("name",""));
                ret.append("</a>");
                ret.append("</li>");                
            }
            
            if(id!=null && id.length()>0)
            {
                DataObject objd=eng.getDataSource(obj.getString("ds")).getObjectByNumId(id);
                if(objd!=null)
                {
                    String name=objd.getNumId();
                    String df=eng.getDataSource(objd.getClassName()).getDisplayField();
                    if(df!=null)name=objd.getString(df);        
                    ret.append("<li "+(last?"class=\"active\"":"")+">");
                    if(!last)ret.append("<a href=\"admin_content?"+getParams(paths, x+1)+"\" data-history=\"#"+obj.getNumId()+"\" data-target=\".content-wrapper\" data-load=\"ajax\">");
                    ret.append(name);
                    if(!last)ret.append("</a>");
                    ret.append("</li>");
                }
            }   
            
            //contextBoxes
            if(!last)
            {
                String contextBox=obj.getString("contextBox","").trim();
                if(!contextBox.isEmpty())
                {
                    contextBox=request.getContextPath()+contextBox+"?id="+id;
                    StringBuilder txt=new StringBuilder();
                    txt.append("<div id=\"pg_"+obj.getNumId()+"\" class=\"col-md-4 callout callout-info lead\">");                    
                    txt.append("</div>"); 
                    txt.append("<script type=\"text/javascript\">");
                    txt.append("loadContent(\""+contextBox+"\",\"#pg_"+obj.getNumId()+"\");");
                    txt.append("</script>");
                    helpBoxes.add(txt.toString());
                }
            }
            
        }
        return ret.toString();
    }
    
    String getParams(DataList<String> paths)
    {
        return getParams(paths, paths.size());
    }
    
    String getParams(DataList<String> paths, int size)
    {
        StringBuilder ret=new StringBuilder();
        ret.append("p=");
        for(int x=0;x<size;x++)
        {
            String n = paths.get(x);
            ret.append(n);
            if(x<size-1)ret.append("/");
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
                int li=id.lastIndexOf(":");
                if(li>-1)last+=id.substring(li);
                paths.add(last);
            }
        }
        return paths;
    }
    
    String getPath(String type, DataList<String> paths)
    {
        String fname=type;        
        if("sc_grid".equals(type) 
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
    
    //Map<String,String[]> pmap=new HashMap();
    //pmap.putAll(request.getParameterMap());    
    
    //Tab
    String t=request.getParameter("t");
    String a=request.getParameter("a");
    //Split path
    DataList<String> paths=getContentPaths(request.getParameterValues("p"),request.getParameter("id"));
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
    
    
    //Find extra parameters
    Map<String,String[]> pmap=new HashMap();
    pmap.putAll(request.getParameterMap());    
    pmap.remove("t");
    pmap.remove("a");
    pmap.remove("p");
    pmap.remove("id");
    StringBuilder extp=new StringBuilder();
    Iterator<String> eit=pmap.keySet().iterator();
    while (eit.hasNext()) {
        String key = eit.next();
        String vals[]=pmap.get(key);
        for(String val:vals)
        {
            extp.append(key);
            extp.append("=");
            extp.append(URLEncoder.encode(val,"UTF-8"));
        }
    }
    
    DataObject obj=eng.getDataSource("Page").getObjectByNumId(pid);   
    //System.out.println(obj);
    String _title=obj.getString("name","");
    String _smallName=obj.getString("smallName","");
    String _ds=obj.getString("ds");
    String _path=obj.getString("path","");
    String _fileName="admin_content";
    String type=obj.getString("type");
    
    if(id!=null && _path.length()>0)
    {
        _path=_path.replace("{id}", id);
        //String sid[]=id.split(":");
        //if(sid.length==4)_path=_path.replace("{ID}", sid[3]);    
    }
    
    //add context
    _path=_path.startsWith("/")?contextPath+_path:_path;
    
    if(extp.length()>0 && _path.length()>0)_path=_path.indexOf("?")>-1?_path+"&"+extp:_path+"?"+extp;

    if(!eng.hasUserAnyRole(obj.getDataList("roles_view")))
    {
        response.sendError(403,"Acceso Restringido...");
        return;
    }
    
    if(obj.getString("status","").equals("disabled"))
    {
        response.sendError(404,"Página no encontrada...");
        return;        
    } 
    
    boolean add=(a!=null);  

    //
    if(_path.length()==0)
    {
        _path+=getPath(type, paths);
    }
    
    //helpBoxes
    DataList<String> helpBoxes=new DataList();     
    String breadcrumb=getPagePath(eng, request, paths, helpBoxes);            
    String helpBox=obj.getString("helpBox","").trim();        
    if(!helpBox.isEmpty())helpBoxes.add("<div class=\"col-md-4 callout callout-info lead\">"+helpBox+"</div>");  

%><!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small><%=_smallName%></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <%=breadcrumb%>
    </ol>
</section>
<!--    
<section class="content-header-desc" style="padding: 3px 15px 0px 15px;">
    <div class="callout callout-info">
        <h4>Tip!</h4>
        <p>Add the layout-top-nav class to the body tag to get this layout. This feature can also be used with a
            sidebar! So use this class if you want to remove the custom dropdown menus from the navbar and use regular
            links instead.
        </p>
    </div>
</section>
-->
<!-- Main content -->
<%
    if(!add && id==null)
    {
%>
<section id="content" style="padding: 7px">  
    <iframe class="ifram_content <%=pid%>" src="<%=_path%>" frameborder="0" width="100%"></iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>                        
</section>
<%
    }else
    {
        DataObject query=new DataObject();
        query.addSubList("sortBy").add("order");
        query.addSubObject("data").addParam("parentId", obj.getId());
        DataList childs=eng.getDataSource("Page").fetch(query).getDataObject("response").getDataList("data");      
        //System.out.println("child:"+childs);
%>
<section id="content" class="content">  
    <div class="row">
        <div class="col-md-<%=helpBoxes.isEmpty()?"12":"8"%>" id="main_content">
            <!-- Custom Tabs -->
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class=""><a href="#info" id="tab_info" data-toggle="tab" aria-expanded="true" ondblclick="loadContent('adm_cnt_iframe?<%=p%><%=(a!=null?"&a="+a:"")%>','#info')" onclick="this.onclick=undefined;this.ondblclick();"><%=add?"Agregar "+_title:"Información"%></a></li>                                        
<%
        if(!add)
        {
            Iterator<DataObject> it=childs.iterator();
            while (it.hasNext()) {
                DataObject tab = it.next();       
                if(!tab.getString("status","active").equals("active"))continue;
                String tabType=tab.getString("type");
                if("ajax_content".equals(tabType))
                {
                    String tabPath=tab.getString("path","");
                    //replace special args
                    tabPath=tabPath.replace("{id}", id);
                    //String sid[]=id.split(":");
                    //if(sid.length==4)tabPath=tabPath.replace("{ID}", sid[3]);
%>
                    <li class=""><a href="#<%=tab.getNumId()%>" id="tab_<%=tab.getNumId()%>" data-toggle="tab" aria-expanded="false" ondblclick="loadContent('<%=tabPath%>','#<%=tab.getNumId()%>')" onclick="this.onclick=undefined;this.ondblclick();"><%=tab.getString("name")%></a></li>
<%                    
                }else
                {
%>
                    <li class=""><a href="#<%=tab.getNumId()%>" id="tab_<%=tab.getNumId()%>" data-toggle="tab" aria-expanded="false" ondblclick="loadContent('adm_cnt_iframe?<%=p%>&p=<%=tab.getNumId()%>','#<%=tab.getNumId()%>')" onclick="this.onclick=undefined;this.ondblclick();"><%=tab.getString("name")%></a></li>
<%
                }
            }   
        }
%>                    
                </ul>
                <div class="tab-content"><div class="tab-pane" id="info"><center>Loading...</center></div>
<%
        if(!add)
        {
            Iterator<DataObject> it=childs.iterator();
            while (!add && it.hasNext()) {
                DataObject tab = it.next();     
                //System.out.println("tab:"+tab.getNumId()+" "+id);
%>
                <div class="tab-pane" id="<%=tab.getNumId()%>"><center>Loading...</center></div><!-- /.tab-pane -->
<%
            }            
        }
%>                    
                </div><!-- /.tab-content -->
                <script type="text/javascript">
                    $('#<%=t!=null?t:"tab_info"%>').trigger("click");
                </script>                                                
            </div><!-- nav-tabs-custom -->
        </div><!-- /.col -->
<%
    for(String txt:helpBoxes)
    {
        out.println(txt);
    }
%>               
    </div>
</section>
<%
    }
%>    
<!-- /.content -->

