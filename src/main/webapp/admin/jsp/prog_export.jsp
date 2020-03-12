<%-- 
    Document   : prog_export.jsp
    Created on : 10-feb-2019, 20:51:20
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page import="org.apache.commons.csv.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.apache.commons.fileupload.disk.*"%><%@page import="org.apache.commons.fileupload.servlet.*"%><%@page import="org.apache.commons.fileupload.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    SWBScriptEngine engd = DataMgr.initPlatform("/admin/ds/datasources.js", session);
    DataObject user = eng.getUser();
    
    String _dsa[]=request.getParameterValues("dsa");
    String _dsd[]=request.getParameterValues("dsd");
    String sname=request.getParameter("name");
    
    if(_dsd!=null || _dsa!=null)
    {        
            String date=DataUtils.TEXT.iso8601DateFormat(new Date());
            response.setHeader("Content-Disposition","attachment; filename=\""+sname+"_"+date+".json\"");
            response.setContentType("text/json");
            if(_dsa!=null)for(String dsn:_dsa)
            {
                try
                {                
                    SWBDataSource ds=eng.getDataSource(dsn);
                    DataObjectIterator it=ds.find();
                    while (it.hasNext()) {
                        DataObject obj = it.next();
                        DataObject rec=new DataObject();
                        rec.addParam("ds", dsn);
                        rec.addParam("uri", ds.getBaseUri());
                        rec.addParam("data", obj);
                        out.println(rec);
                    }
                }catch(Exception e){
                    e.printStackTrace();
                }                                
            }                          
            
            if(_dsd!=null)for(String dsn:_dsd)
            {
                try
                {                
                    SWBDataSource ds=eng.getDataSource(dsn);
                    DataObjectIterator it=ds.find();
                    while (it.hasNext()) {
                        DataObject obj = it.next();
                        DataObject rec=new DataObject();
                        rec.addParam("ds", dsn);
                        rec.addParam("uri", ds.getBaseUri());
                        rec.addParam("data", obj);
                        out.println(rec);
                    }
                }catch(Exception e){
                    e.printStackTrace();
                }                                
            }
        return;        
    }

%>
        <section class="content-header">
            <h1>Export Data<small></small>
            </h1>
            <ol class="breadcrumb">
                <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
                <li>Programación</li>
                <li><a href="#">Utils</a></li>        
                <li class="active"><a href="#">Export Data</a></li>        
            </ol>
        </section>
        
        <div class="box-body">
            <div class="col-md-12" style="background: white">
                <h4>Data Export Utility</h4>
                <form method="POST" action="<%=contextPath%>/admin/prog_export" data-target_=".content-wrapper" data-submit_="ajax" role="form">
                    <!-- COMPONENT START -->
                    <div class="form-group">
                    <b>Admin DataSources:<b>
                    <select id="dsa" name="dsa" class="form-control" multiple>
<%
    TreeSet<String> set=new TreeSet();
    set.addAll(engd.getDataSourceNames());
    
    for(Object name:eng.getDataSourceNames().stream().sorted().toArray())
    {
        if(!set.contains(name))
        {
%>                        
                        <option value="<%=name%>"><%=name%></option>
<%       
        }
    }
%>                        
                    </select>                        
                    <b>App DataSources:</b>
                    <select id="dsd" name="dsd" class="form-control" multiple>
<%
    for(String name:set)
    {
%>                        
                        <option value="<%=name%>"><%=name%></option>
<%        
    }
%>                        
                    </select>   
                    <b>File Name:</b><br>
                    <input type="text" name="name" value="export" style="width:100%">
                    </div>
                    <!-- COMPONENT END -->
                    <div class="form-group">
                        <button class="btn btn-default" onclick="selectAll('dsd',true);selectAll('dsa',true);return false;">Select All</button>
                        <button class="btn btn-default" onclick="selectAll('dsd',false);selectAll('dsa',false);return false;">Select None</button>
                        <button type="submit" class="btn btn-primary">Export</button>
                        <!--<button type="reset" class="btn btn-danger">Reset</button>-->
                    </div>                    
                </form>
            </div>
        </div>        

        <script type="text/javascript">
            function selectAll(selectBox,selectAll) { 
                // have we been passed an ID 
                if (typeof selectBox == "string") { 
                    selectBox = document.getElementById(selectBox);
                } 
                // is the select box a multiple select box? 
                if (selectBox.type == "select-multiple") { 
                    for (var i = 0; i < selectBox.options.length; i++) { 
                         selectBox.options[i].selected = selectAll; 
                    } 
                }
            }
        </script>