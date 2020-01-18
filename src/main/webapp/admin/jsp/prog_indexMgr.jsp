<%-- 
    Document   : InvTarjetasBancoAzteca
    Created on : 10-feb-2019, 20:51:20
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page import="org.apache.commons.csv.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.apache.commons.fileupload.disk.*"%><%@page import="org.apache.commons.fileupload.servlet.*"%><%@page import="org.apache.commons.fileupload.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    SWBScriptEngine engd = DataMgr.initPlatform("/admin/ds/datasources.js", session);
    DataObject user = eng.getUser();
    
    String action=request.getParameter("action");
%>
        <section class="content-header">
            <h1>Index Manager<small></small>
            </h1>
            <ol class="breadcrumb">
                <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
                <li>Programación</li>
                <li><a href="#">Utils</a></li>        
                <li class="active"><a href="#">Index Manager</a></li>        
            </ol>
        </section>
        
        <div class="box-body">
            <div class="col-md-12" style="background: white">
                
<%
    DataObject indexes=new DataObject();
    {        
        DataObjectIterator it=eng.getDataSource("DataSource").find();
        while (it.hasNext()) {
            DataObject obj = it.next();
            if(!obj.getBoolean("backend") && !obj.getBoolean("frontend"))continue;

            DataObject query=new DataObject();
            query.addSubList("sortBy").add("order");
            query.addSubObject("data").addParam("ds", obj.getId());
            DataObjectIterator it2=eng.getDataSource("DataSourceFields").find(query);
            //System.out.println("size:"+it2.size()+":"+it2.total());
            while (it2.hasNext()) {
                DataObject fobj = it2.next();
                boolean req=fobj.getBoolean("required");
                String name=fobj.getString("name");
                String type=fobj.getString("type");
                String dataSource=null;
                String valueField=null;
                boolean multiple=false;

                query=new DataObject();
                query.addSubObject("data").addParam("dsfield", fobj.getId());
                DataObjectIterator it3=eng.getDataSource("DataSourceFieldsExt").find(query);
                while (it3.hasNext()) {
                    DataObject feobj = it3.next();
                    String att=feobj.getString("att");
                    String value=feobj.getString("value");   

                    if(att.equals("stype"))type+="("+value+")";
                    if(att.equals("dataSource"))
                    {
                        dataSource=value;
                        //if(valueField==null)valueField="_id";
                    }
                    if(att.equals("valueField"))valueField=value;                    
                    if(att.equals("multiple"))multiple=Boolean.parseBoolean(value);
                }

                if(dataSource!=null)
                {
                    if(eng.getDataSource(dataSource)==null)continue;                    
                    String dispField=eng.getDataSource(dataSource).getDisplayField();
                    if(dispField!=null)
                    {
                        indexes.getOrCreateDataObject(dataSource).addParam(dispField, 0);
                    }
                    
                    if(valueField!=null)
                    {
                        indexes.getOrCreateDataObject(dataSource).addParam(valueField, 0);
                    }
                }     
            }
        }
    }
        
    //Find indexes
    DataObject mapIndex=eng.getDataSource("DataSourceIndex").mapById();
    DataObjectIterator itx=eng.getDataSource("DataSourceIndexFields").find();
    while (itx.hasNext()) {
        DataObject indfield = itx.next();
        mapIndex.getDataObject(indfield.getString("dsindex")).getOrCreateDataList("fields").add(indfield.getString("prop"));
    }
    //System.out.println("mapIndex:"+mapIndex);

    //compare indexes
    StringBuilder dataO=new StringBuilder();
    Iterator ity=mapIndex.values().iterator();
    while (ity.hasNext()) {
        DataObject i = (DataObject)ity.next();
        String ds=i.getString("ds");
        ds=ds.substring(ds.lastIndexOf(":")+1);
        DataList f=i.getOrCreateDataList("fields");
        boolean added=false;
        if(f.size()==1)
        {
            String field=f.getString(0);
            field=field.substring(field.lastIndexOf(".")+1);
            if(indexes.containsKey(ds))
            {
                if(indexes.getDataObject(ds).containsKey(field))
                {
                    indexes.getDataObject(ds).put(field,1);
                    added=true;
                }
            }
        }
        if(!added)dataO.append(i.getString("name")+":"+f);
    }
    
        
    
                
    //Process Display
    StringBuilder dataI=new StringBuilder();
    StringBuilder dataE=new StringBuilder();
    Iterator<String> it2=indexes.keySet().iterator();
    while (it2.hasNext()) {
        String dataSource = it2.next();
        DataObject objField=indexes.getDataObject(dataSource);

        Iterator<String> it3=objField.keySet().iterator();
        while (it3.hasNext()) {
            String field = it3.next();
            int i=objField.getInt(field);
            
            //Create Indexes
            if(action!=null && i==0 && action.equals("sugg"))
            {
                SWBDataSource ds=eng.getDataSource("DataSource");
                SWBDataSource dsi=eng.getDataSource("DataSourceIndex");
                SWBDataSource dsif=eng.getDataSource("DataSourceIndexFields");
                DataObject obj=new DataObject();
                obj.addParam("ds", ds.getBaseUri()+dataSource);
                obj.addParam("name", dataSource+"_"+field);
                obj.addParam("description", "Index created by IndexMgr");
                obj=dsi.addObj(obj).getDataObject("response").getDataObject("data");
                DataObject fi=new DataObject();
                fi.addParam("dsindex", obj.getId());
                fi.addParam("prop", dataSource+"."+field);
                fi.addParam("type", "1");
                dsif.addObj(fi);
                i=1;
            }
            
            if(i==1){
                dataI.append(dataSource+"."+field+"\n");
            }else {
                dataE.append(dataSource+"."+field+"\n");
            }
        }
    }        
       
%>                
                <h4>Created Index</h4>
                <pre><%=dataI%></pre>
                <h4>Suggested Index</h4>
                <pre><%=dataE%></pre>
                <h4>Other Index</h4>
                <pre><%=dataO%></pre>
                <form method="POST" action="<%=contextPath%>/admin/prog_indexMgr" data-target=".content-wrapper" data-submit="ajax" role="form">
                    <!-- COMPONENT START -->
                    <div class="form-group">
                        <input type="hidden" name="action">
                    </div>
                    <!-- COMPONENT END -->
                    <div class="form-group">
                        <button type="submit" value="sugg" onclick="form.action.value=this.value" class="btn btn-primary">Create Suggested Index</button>
                    </div>                    
                </form>
            </div>
        </div>        

        <script type="text/javascript">

        </script>