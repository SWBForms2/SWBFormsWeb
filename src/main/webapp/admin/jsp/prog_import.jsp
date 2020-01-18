<%-- 
    Document   : InvTarjetasBancoAzteca
    Created on : 10-feb-2019, 20:51:20
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page import="org.apache.commons.csv.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.apache.commons.fileupload.disk.*"%><%@page import="org.apache.commons.fileupload.servlet.*"%><%@page import="org.apache.commons.fileupload.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    DataObject importData=null;
    boolean uploading=false;
%><%
    String contextPath = request.getContextPath();     
    final SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    final HttpServletRequest req=request;
    DataObject user = eng.getUser();
    
    if(!uploading)
    {
        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        //System.out.println("isMultipart:"+isMultipart);
        if(isMultipart)
        {   
            uploading=true;
            eng.setDisabledDataTransforms(true);
            try
            {
                // Create a new file upload handler
                ServletFileUpload upload = new ServletFileUpload();

                // Parse the request
                FileItemIterator iter = upload.getItemIterator(req);
                while(iter.hasNext())
                {
                    FileItemStream item = iter.next();
                    if (!item.isFormField()) {
                        BufferedReader in = new BufferedReader(new InputStreamReader(item.openStream(),"UTF-8")); 
                        String line=null;
                        importData=new DataObject();
                        while ((line = in.readLine()) != null) {
                            DataObject obj=(DataObject)DataObject.parseJSON(line);
                            String sds=obj.getString("ds");
                            String suri=obj.getString("uri");
                            String sbase=suri.substring(0,suri.indexOf(":", 6)+1);

                            if(importData.incLong(sds, 1)==1)
                            {
                                SWBDataSource ds=eng.getDataSource(sds);
                                if(ds==null)
                                {
                                    System.out.println("reload SE:"+sds);
                                    eng.reloadAllScriptEngines();
                                }else
                                {
                                    System.out.println("clear:"+sds);
                                    DataObject query=new DataObject().addParam("removeByID", false);
                                    query.addSubObject("data");
                                    ds.remove(query);
                                }
                            }                                        

                            SWBDataSource ds=eng.getDataSource(sds);
                            if(ds!=null)
                            {
                                String sdata=obj.getString("data");
                                sdata=sdata.replace("\""+sbase, "\"_suri:"+ds.getModelId()+":");
                                DataObject data=(DataObject)DataObject.parseJSON(sdata);
                                ds.addObj(data);
                            }
                        }
                    }
                }
            }finally{
                uploading=false;
                eng.setDisabledDataTransforms(false);
                eng.needsReloadAllScriptEngines();
            }
            return;   
        }
    }    
%>
<%
    if(importData==null)
    {
%>                
        <section class="content-header">
            <h1>Import Data <small></small>
            </h1>
            <ol class="breadcrumb">
                <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
                <li>Programación</li>
                <li><a href="#">Utils</a></li>        
                <li class="active"><a href="#">Import Data</a></li>        
            </ol>
        </section>
        
        <div class="box-body">
            <div class="col-md-12" style="background: white">                
                <h4>Importar archivo</h4>
                <form method="POST" target="iframe" action="/admin/prog_import" enctype="multipart/form-data">
                    <!-- COMPONENT START -->
                    <div class="form-group">
                        <div class="input-group input-file" name="file">
                            <span class="input-group-btn">
                                <button class="btn btn-default btn-choose" type="button">Seleccionar</button>
                            </span>
                            <input type="text" class="form-control" placeholder='Choose a file...' />
                        </div>
                    </div>
                    <!-- COMPONENT END -->
                    <div class="form-group">
                        <button type="submit" onclick="reload();return true;" class="btn btn-primary">Enviar</button>
                    </div>                    
                </form>
                <iframe style="display: none" name="iframe"></iframe>
                <div id="import"></div>
            </div>
        </div>        

        <script type="text/javascript">
            function bs_input_file() {
                $(".input-file").before(
                        function () {
                            if (!$(this).prev().hasClass('input-ghost')) {
                                var element = $("<input type='file' class='input-ghost' style='visibility:hidden; height:0'>");
                                element.attr("name", $(this).attr("name"));
                                element.change(function () {
                                    element.next(element).find('input').val((element.val()).split('\\').pop());
                                });
                                $(this).find("button.btn-choose").click(function () {
                                    element.click();
                                });
                                $(this).find("button.btn-reset").click(function () {
                                    element.val(null);
                                    $(this).parents(".input-file").find('input').val('');
                                });
                                $(this).find('input').css("cursor", "pointer");
                                $(this).find('input').mousedown(function () {
                                    $(this).parents('.input-file').prev().click();
                                    return false;
                                });
                                return element;
                            }
                        }
                );
            }
            $(function () {
                bs_input_file();
            });
            
            function reload(){
                setTimeout(function(){loadContent("/admin/prog_import","#import");},1000);
            };
        </script>
<%
    }else
    {
%>
                <h4>Importar archivo</h4>
                <pre><%
        for(String key:importData.keySet())
        {
            out.println(key+":"+importData.getString(key));
        }
%></pre>
<%
        if(uploading)
        {
%>
        <script type="text/javascript">
            reload();
        </script>
<%            
        }else
        {
            importData=null;
        }
    }
%>    
