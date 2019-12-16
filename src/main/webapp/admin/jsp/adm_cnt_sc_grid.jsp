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
        
    public String parseScript(String txt, HttpServletRequest request, DataObject user)
    {
        if(txt==null)return "";    

        Iterator it=DataUtils.TEXT.findInterStr(txt, "{$getParameter:", "}");
        while(it.hasNext())
        {
            String s=(String)it.next();
            String k=s.trim();
            if((k.startsWith("'") && k.endsWith("'")) || (k.startsWith("\"") && k.endsWith("\"")))k=k.substring(1,k.length()-1);
            String replace=request.getParameter(k);
            if(replace==null)replace="";
            txt=txt.replace("{$getParameter:"+s+"}", replace);
        }

        it=DataUtils.TEXT.findInterStr(txt, "{$user:", "}");
        while(it.hasNext())
        {
            String s=(String)it.next();
            String k=s.trim();
            if((k.startsWith("'") && k.endsWith("'")) || (k.startsWith("\"") && k.endsWith("\"")))k=k.substring(1,k.length()-1);
            String replace=user.getString(k,"");
            txt=txt.replace("{$user:"+s+"}", replace);
        }
        return txt;
    }    

    public StringBuilder getFields(DataObject obj, String propsField, DataList extProps, SWBScriptEngine eng, boolean mode_add)
    {
        StringBuilder fields=new StringBuilder();
        DataList gridProps=obj.getDataList(propsField);
        DataList empty=new DataList();
        if(gridProps!=null)
        {
            Iterator<String> it=gridProps.iterator();
            while (it.hasNext()) {
                String _id = it.next();
                String name=_id.substring(_id.indexOf(".")+1);
                //System.out.println(_id);
                boolean add=true;
                StringBuilder row=new StringBuilder();
                row.append("{");
                row.append("name:"+"\""+name+"\"");
                for(int i=0;i<extProps.size();i++)
                {
                    DataObject ext=extProps.getDataObject(i);
                    if(ext.getDataList("prop",empty).contains(_id))
                    {
                        String att=ext.getString("att");
                        if(att.equals("canEditRoles")) {
                            boolean enabled = true;
                            if(att.equals("canEditRoles"))enabled=eng.hasUserAnyRole(ext.getString("value").split(","));
                            row.append(", disabled:"+!enabled);
                        }else if(att.equals("canViewRoles")) {
                            boolean visible = eng.hasUserAnyRole(ext.getString("value").split(","));
                            row.append(", visible:"+visible);
                            add=visible;
                        }else if(att.equals("validators")) {
                            row.append(", "+att+":[");
                            Object value=ext.get("value");
                            if (value instanceof DataList) {
                                DataList list = (DataList) value;
                                Iterator<String> it4 = list.iterator();
                                while (it4.hasNext()) {
                                    String val = it4.next();
                                    //ret.append("{stype: \""+val+"\"}");
                                    row.append("eng.validators[\"" + val + "\"]");
                                    if (it4.hasNext()) {
                                        row.append(",");
                                    }
                                }
                            } else {
                                String vals[] = value.toString().split(",");
                                for (int j = 0; j < vals.length; j++) {
                                    row.append("eng.validators[\"" + vals[j] + "\"]");
                                    if (j + 1 < vals.length) {
                                        row.append(",");
                                    }
                                }
                            }
                            row.append("]");
                        }else {
                            // original
                            String value=ext.getString("value");
                            String type=ext.getString("type");
                            row.append(", "+att+":");
                            if("string".equals(type) || "date".equals(type))
                            {
                                row.append("\""+value+"\"");
                            }else
                            {
                                row.append(value);
                            }
                            // fin. original
                        }
                    }
                }
                row.append("}");
                if(it.hasNext())row.append(",");
                if(add)fields.append(row);
                fields.append("\n");
            }
        }    
        return fields;
    }    
    
    public StringBuilder getProps(DataList extProps, HttpServletRequest request, DataObject user)
    {
        StringBuilder fields=new StringBuilder();
        DataList empty=new DataList();
        for(int i=0;i<extProps.size();i++)
        {
            DataObject ext=extProps.getDataObject(i);
            if(ext.getDataList("prop",empty).isEmpty())
            {
                String att=ext.getString("att");
                String value=parseScript(ext.getString("value"),request,user);
                String type=ext.getString("type");
                fields.append(att+":");
                if("string".equals(type) || "date".equals(type))
                {
                    fields.append("\""+value+"\"");
                }else
                {
                    fields.append(value);
                }
                fields.append(",\n");
            }
        }
        return fields;
    }      
    
    public DataList getExtProps(DataObject obj, String extPropsField, SWBScriptEngine eng) throws IOException
    {
        DataList extProps=new DataList();
        DataList data=obj.getDataList(extPropsField);
        if(data!=null)
        {
            DataObject query=new DataObject();
            query.addSubObject("data").addParam("_id", data);
            extProps=eng.getDataSource("PageProps").fetch(query).getDataObject("response").getDataList("data");
        }
        return extProps;
    }  

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
    
    if(obj==null)
    {
        response.sendError(404,"Página "+pid+" no encontrada...");
        return;        
    }     
    
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
    String _title=obj.getString("name","");
    String _ds=obj.getString("ds");
    String _fileName="admin_content";
    String type=obj.getString("type");    
    DataList gd_conf=obj.getDataList("gd_conf",new DataList());
    
    StringBuilder fields;
    DataList extProps;
    if("process_tray".equals(type))
    {
        extProps=getExtProps(obj,"gridExtProps",eng);
        fields=getFields(obj, "gridProps", extProps, eng, add);
    }else if(!add && id==null && !"sc_form".equals(type))
    {
        extProps=getExtProps(obj,"gridExtProps",eng);
        fields=getFields(obj, "gridProps", extProps, eng, add);
    }else
    {
        extProps=getExtProps(obj,"formExtProps",eng);
        fields=getFields(obj, "formProps", extProps, eng, add);
    }
    

    //busca link hacia pagina padre
    String linkProp=null;
    String linkValue=null;    
    if(id==null && paths.size()>1)
    {        
        String pid2=paths.get(paths.size()-2);
        String id2=null;
        int i2=pid2.indexOf(":");
        if(i2>-1)
        {
            id2=pid2.substring(i2+1);
            pid2=pid2.substring(0,i2);

            DataObject obj2=eng.getDataSource("Page").getObjectByNumId(pid2);
            if(obj2!=null)
            {
                String psds=obj2.getString("ds");
                String sds=obj.getString("ds");
                String name=null;
                String value=eng.getDataSource(obj2.getString("ds")).getBaseUri()+id2;
                Iterator<ScriptObject> it=eng.getDataSource(sds).findScriptFields("dataSource", psds).iterator();
                if (it.hasNext()) {
                    ScriptObject field = it.next();
                    name=field.getString("name");
                    String valueField=field.getString("valueField");
                    if(valueField!=null)
                    {
                        value=eng.getDataSource(psds).getObjectById(value,DataObject.EMPTY).getString(valueField);
                    }
                }
                if(name!=null)
                {
                    linkProp=name;
                    linkValue=value;
                }
            }
        } 
    }

%>
<!DOCTYPE html>
<html>
    <head>
        <title><%=_title%></title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="adm_sc_head.jsp"%>
    </head>
    <body>
      <div>
        <script type="text/javascript">
            eng.initPlatform("<%=obj.getString("engine","/admin/ds/datasources.js")%>", true);
        </script>
        <script type="text/javascript">            
<%
        if(!add && id==null && !"sc_form".equals(type))
        {
           if("sc_search_detail".equals(type))
            {
                DataList searchExtProps=getExtProps(obj,"searchExtProps",eng);
                StringBuilder searchFields=getFields(obj, "searchProps", searchExtProps, eng, add);
%>
            var form = eng.createForm({
                width: "100%",
                left: "-8px",
                autoComplete: "none",
                canEdit: true,
                canPrint: false,
                showTabs: false,
                numCols: 4,
                colWidths: [250, "*"],   
                <%=getProps(searchExtProps,request,user)%>
                fields: [<%=searchFields%>]   
            }, null, "<%=_ds%>");
            
            if(form.submitButton){
                form.submitButton.setTitle("Filtrar");
                form.submitButton.click = function (p1 )
                {
                    grid.filterData(form.getValuesAsCriteria());
                };    
            }
<%                
            }else if("sc_fulltext_search_detail".equals(type))
            {
%>
                function submitForm(form)
                {
                    var q=form.q.value;
                    if(q)
                    {
                        if(q.search(/[-+\"]/)==-1)q="\""+q.split(" ").join("\" \"")+"\"";
                        console.log(q);
                        grid.filterData({$text:{$search:q}});
                    }else grid.filterData({});
                    return false;
                }
                document.write("<form onsubmit=\"return submitForm(this)\">");
                document.write("<input type=\"text\" name=\"q\" style=\"width: calc(100% - 116px); height: 21px; float: left; color: rgb(40, 40, 40); font-size: 15px; font-family: RobotoLight;\" placeholder=\"Texto a Buscar\">");
                document.write("<input type=\"submit\" style=\"float: right; width: 100px; background-color: #157fcc; border: 2px solid #157fcc; line-height: 20px; color: white; font-size: 13px; margin: 0px 0px 10px 10px;\" value=\"Buscar\">");
                document.write("</form>");
<%                
            }

            //********************************** Grid ************************************************************
%>            
            var grid=eng.createGrid({
                autoResize: true,
                resizeHeightMargin: <%=type.endsWith("search_detail")?300:30%>,
                resizeWidthMargin: 15,
                canEdit: <%=eng.hasUserAnyRole(obj.getDataList("roles_update"))%>,
                canAdd: <%=eng.hasUserAnyRole(obj.getDataList("roles_add"))%>,
                canRemove: <%=eng.hasUserAnyRole(obj.getDataList("roles_remove"))%>,
                <%if(!type.endsWith("search_detail")){%>showFilter: true,<%}%>         
                <%if(type.endsWith("search_detail")){%>autoFetchData: false,<%}%>
                <%=getProps(extProps,request,user)%>
                <%if(linkProp!=null){out.println("initialCriteria: {'"+linkProp+"':'"+linkValue+"'},");}%>
<%
            if("sc_grid_detail".equals(type) || type.endsWith("search_detail"))
            {
                if(gd_conf.contains("inlineEdit"))
                {
                    fields.append(",{name: \"edit\", title: \" \", width:32, canEdit:false, formatCellValue: function (value) {return \" \";}}");
%>
                showRecordComponents: true,
                showRecordComponentsByCell: true,
                //recordComponentPoolingMode: "recycle",
                
                createRecordComponent: function (record, colNum) {
                    var fieldName = this.getFieldName(colNum);
                    
                    if (fieldName == "edit") {
                        var content=isc.HTMLFlow.create({
                            width:32,
                            height:16,
                            contents:"<img style=\"cursor: pointer; padding: 5px 11px;\" width=\"16\" height=\"16\" src=\"<%=contextPath%>/platform/isomorphic/skins/Tahoe/images/actions/edit.png\">", 
                            //dynamicContents:false,
                            click: function () {
                                var id=record["_id"];
                                if(id!=null)id=id.substring(id.lastIndexOf(":")+1);
                                parent.loadContent("<%=_fileName%>?<%=p%>:" + id,".content-wrapper",null,null,"#<%=p.substring(2)%>:"+ id);
                                return false;
                            }
                        });
                        return content;
                    } else {                    
                        return null;
                    }
                },                     
<%        
                }else
                {
%>                  
                recordDoubleClick: function(grid, record)
                {
                    var id=record["_id"];
                    if(id!=null)id=id.substring(id.lastIndexOf(":")+1);
                    parent.loadContent("<%=_fileName%>?<%=p%>:"+ id,".content-wrapper",null,null,"#<%=p.substring(2)%>:"+ id);
                    return false;
                },
<%
                }
                if(!gd_conf.contains("inlineAdd"))
                {
%>                
                addButtonClick: function(event)
                {
                    parent.loadContent("<%=_fileName%>?<%=p%>&a=1",".content-wrapper",null,null,"#<%=obj.getNumId()%>_add");
                    return false;
                },                                 
<%
                }
            }
%>                
                fields: [<%=fields%>]           
            }, "<%=_ds%>");
            
            <%=parseScript(obj.getString("gridAddiJS"),request,user)%>
<%
            //********************************** End Grid ************************************************************    
        }else
        {
            //********************************** Form ************************************************************
            String sid = null;

            if(linkProp!=null)
            {
                DataObject inst=eng.getDataSource(_ds).fetchObjByProp(linkProp, linkValue);
                if(inst==null)add=true;
                else sid="\""+inst.getId()+"\"";
            }else
            {
                sid = add?"null":"\"" + eng.getDataSource(obj.getString("ds")).getObjectByNumId(id,DataObject.EMPTY).getId() + "\"";
            }
%>
            var form = eng.createForm({
                width: "100%",
                left: "-8px",
                title: "Información",
                autoComplete: "off",
                showTabs: false,
                canPrint: false,
                canEdit: <%=(eng.hasUserAnyRole(obj.getDataList("roles_update")) || (eng.hasUserAnyRole(obj.getDataList("roles_add")) && add))%>,
                <%=(eng.findFormProcessors(_ds, SWBDataSource.ACTION_INIT)!=null)?"processInit: true,":""%>
                <%=(eng.findFormProcessors(_ds, SWBDataSource.ACTION_CHANGE)!=null)?"processChange: true,":""%>
                numCols: 2,
                colWidths: [250, "*"],
                requiredTitlePrefix: "<b>* ",
                requiredTitleSuffix: "</b>",                
                <%=getProps(extProps,request,user)%>
                fields: [<%=fields%>],
                <%if(linkProp!=null){out.println("values: {'"+linkProp+"':'"+linkValue+"'},");}%>
                onLoad:function()
                {
                    setTimeout(function(){
                        parent.$(".<%=pid%>").attr("height", Math.max(document.body.offsetHeight+16,window.innerHeight-110) + "px");
                    },0);
                }
            }, <%=sid%>, "<%=_ds%>");

            if(form.submitButton){
                form.submitButton.setTitle("Guardar");
                form.submitButton.click = function (p1)
                {
                    eng.submit(form, this, function ()
                    {
                        isc.say("Datos enviados correctamente...", function () {                        
                            <%if(add){%>parent.loadContent("<%=_fileName%>?<%=p%>&id=" + form.values._id,".content-wrapper");<%}%>
                        });
                    });
                };
            }

            form.buttons.addMember(isc.IButton.create({
                title: "Regresar",
                padding: "10px",
                click: function (p1) {     
<%
    //Identificar path de retorno
    String retPath=(id!=null?p.substring(0,p.lastIndexOf(":")):p);
    if(paths.size()>1)
    {
        String pt=retPath.substring(0,retPath.lastIndexOf("/"));
        if(id!=null && pt.endsWith(id))
        {
            retPath=retPath.substring(0,retPath.lastIndexOf(":"));
        }else
        {
            retPath=pt+"&t="+retPath.substring(retPath.lastIndexOf("/")+1);
        }
    }    
%>                
                    parent.loadContent("<%=_fileName%>?<%=retPath%>",".content-wrapper");
                    return false;
                }
            }));
            form.buttons.members.unshift(form.buttons.members.pop());  
            //form.layout.members.unshift(form.topButtons);
            //form.topButtons.align="left";
            
            
            <%=parseScript(obj.getString("formAddiJS"),request,user)%>
<%
            //********************************** End Form ************************************************************    
        }
%>    
        </script>         
      </div>
    </body>
</html>