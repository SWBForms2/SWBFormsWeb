<%@page import="org.semanticwb.datamanager.script.*"%><%@page import="java.util.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.net.URLEncoder"%><%@page contentType="text/json" pageEncoding="UTF-8"%><%!


%><%
    String dspath="/demo/datasources.js";
    DataObject user = (DataObject) session.getAttribute("_USER_");
    SWBScriptEngine engine = DataMgr.getUserScriptEngine(dspath, user,false);       //
        
    String q=DataUtils.readInputStream(request.getInputStream());
        
    String t = request.getParameter("t");
    String s = request.getParameter("s");
    //String q = request.getParameter("q");
/*
    System.out.println("t:"+t);
    System.out.println("s:"+s);
    System.out.println("q:"+q);        
*/    
    if(t!=null)
    {
        if("cls".equals(t))
        {
            DataList arr=new DataList();
            Iterator<String> dsnames=engine.getDataSourceNames().iterator();
            while(dsnames.hasNext())
            {
                String name=dsnames.next();
                DataObject obj=new DataObject();
                arr.add(obj);
                obj.put("value", name);
                obj.put("label", name);
                obj.put("ext", new DataObject());
            }
            out.print(arr.toString());
            return;
        }else 
        {
            DataList arr=(DataList)DataObject.parseJSON(q);
            if(q!=null && q.length() > 0)
            {                
                if(arr.size()>0)
                {
                    DataObject c=null;
                    //buscar ultima clase
                    for(int i=arr.size()-1;i>=0;i--)
                    {
                        c=(DataObject)arr.get(i);
                        if("cls".equals(c.getString("category")))
                        {
                            break;
                        }
                    }
                    if(c!=null)
                    {
                        String scls=c.getString("value");
                        String sprop=t;
                        //mostrar propiedades de una clase
                        if (scls != null)
                        {
                            arr=new DataList();
                            SWBDataSource ds=engine.getDataSource(scls);
                            if(ds!=null)
                            {
                                ScriptObject field=ds.getDataSourceScriptField(sprop);
                                String dataSource=field.getString("dataSource");
                                if(dataSource!=null)
                                {
                                    DataObject obj=new DataObject();
                                    arr.add(obj);
                                    obj.put("value", dataSource);
                                    obj.put("label", dataSource);
                                    obj.put("ext", new DataObject());
                                }
                            }
                            out.print(arr.toString());
                            return;                         
                        }
                    }
                }
            }                         
            out.println(arr.toString());                
        }
        return;
    }else 
    {
        if(q!=null && q.length() > 0)
        {
            DataList arr=(DataList)DataObject.parseJSON(q);
            if(arr.size()>0)
            {
                DataObject c=null;
                //buscar ultima clase
                for(int i=arr.size()-1;i>=0;i--)
                {
                    c=(DataObject)arr.get(i);
                    if("cls".equals(c.getString("category")))
                    {
                        break;
                    }
                }
                if(c!=null)
                {
                    String scls=c.getString("value");
                    //mostrar propiedades de una clase
                    if (scls != null)
                    {
                        arr=new DataList();
                        SWBDataSource ds=engine.getDataSource(scls);
                        if(ds!=null)
                        {
                            ScriptObject script=ds.getDataSourceScript();
                            Iterator<ScriptObject> fields=script.get("fields").values().iterator();
                            while(fields.hasNext())
                            {
                                ScriptObject field=fields.next();
                                DataObject obj=new DataObject();
                                arr.add(obj);
                                obj.put("value", field.getString("name"));
                                obj.put("label", field.getString("title"));
                                DataObject ext=new DataObject();
                                obj.put("ext", ext);
                                if(field.getString("dataSource")==null)
                                    ext.put("type", "data");
                                else 
                                    ext.put("type", "obj");
                            }
                        }
                        out.print(arr.toString());
                        return;                         
                    }
                }
            }
        }        
    }        
%>[{"value":"cls","label":"DataSource","ext":{}}]