<%-- 
    Document   : InvTarjetasBancoAzteca
    Created on : 10-feb-2019, 20:51:20
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page import="org.apache.commons.csv.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.apache.commons.fileupload.disk.*"%><%@page import="org.apache.commons.fileupload.servlet.*"%><%@page import="org.apache.commons.fileupload.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
%><%
    String contextPath = request.getContextPath();     
    final SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    final HttpServletRequest req=request;
    DataObject user = eng.getUser();
    
    boolean isMultipart = ServletFileUpload.isMultipartContent(request);
    //System.out.println("isMultipart:"+isMultipart);
    if(isMultipart)
    {   
        eng.getData().addParam("_swf_uploading", true);
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
                    DataObject importData=new DataObject();
                    eng.getData().addParam("_swf_importData", importData);
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
            eng.getData().addParam("_swf_uploading", false);
            eng.setDisabledDataTransforms(false);
        }
        return;   
    }
%>
