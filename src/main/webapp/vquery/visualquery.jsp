<%@page import="org.semanticwb.datamanager.query.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="org.json.*"%><%@page import="java.util.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    QueryDefinition getQueryDefinition(String q, String lang) {
        DataList arr = (DataList) DataObject.parseJSON(q);
        QueryDefinition def = new QueryDefinition();

        for (int x = 0; x < arr.size(); x++) {
            DataObject obj = (DataObject) arr.get(x);
            String category = obj.getString("category");
            String name = obj.getString("name");
            String value = obj.getString("value");
            if ("cls".equals(category)) {
                def.addQueryObject(value, name);
            } else {
                def.addQueryProperty(category, name, value);
            }
        }
        return def;
    }
%>
<%
    String dspath = "/demo/datasources.js";
    String lang = "es";
    String q = DataUtils.readInputStream(request.getInputStream());

        //out.println("q:"+q);        
        //String q="[{\"category\":\"cls\",\"value\":\"itzaak:Patient\",\"name\":\"?Patient1\"},{\"category\":\"itzaak:personFirstName\",\"value\":\"?\",\"name\":\"?personFirstName1\"},{\"category\":\"itzaak:personLastName\",\"value\":\"?\",\"name\":\"?personLastName1\"},{\"category\":\"itzaak:personDemographic\",\"value\":\"itzaak:Demographic\",\"name\":\"?Demographic1\"},{\"category\":\"cls\",\"value\":\"itzaak:Demographic\",\"name\":\"?Demographic1\"},{\"category\":\"itzaak:demographicDomicile\",\"value\":\"itzaak:Domicile\",\"name\":\"?Domicile1\"},{\"category\":\"cls\",\"value\":\"itzaak:Domicile\",\"name\":\"?Domicile1\"},{\"category\":\"itzaak:domicileAddress\",\"value\":\"?\",\"name\":\"?domicileAddress1\"},{\"category\":\"itzaak:domicileZipCode\",\"value\":\"itzaak:ZipCode\",\"name\":\"?ZipCode1\"},{\"category\":\"cls\",\"value\":\"itzaak:ZipCode\",\"name\":\"?ZipCode1\"},{\"category\":\"swb:title\",\"value\":\"?\",\"name\":\"?title2\"}]";
    QueryDefinition def = getQueryDefinition(q, lang);
    String query = def.toString();
%>        
<br/>
<div id="content_over" style="background: whitesmoke;padding: 10px;">
    <div id_="gridExpediente">        
        <%
            try {
                DataObject user = (DataObject) session.getAttribute("_USER_");
                QueryManager mgr = new QueryManager(dspath, user, def);
                mgr.preload();
                DataObject ret = mgr.execute();
                //out.print(ret);

                out.println("<table id='query-data' class='display'>");
                out.println("<thead>");
                out.println("<tr>");
                DataList props = ret.getDataList("props");
                for (int x = 0; x < props.size(); x++) {
                    DataObject prop = props.getDataObject(x);
                    String name = prop.getString("title") + "(" + prop.getString("ds") + ")";
                    out.println("<th>");
                    out.println(name);
                    out.println("</th>");
                }
                out.println("</tr>");
                out.println("</thead>");
                out.println("<tbody>");
                DataList data = ret.getDataList("data");
                for (int x = 0; x < data.size(); x++) {
                    DataObject obj = data.getDataObject(x);
                    out.println("<tr>");
                    for (int y = 0; y < props.size(); y++) {
                        String name = props.getDataObject(y).getString("name");
                        out.println("<th>");
                        out.println(obj.getString(name));
                        out.println("</th>");
                    }
                    out.println("</tr>");
                }
                out.println("</tbody>");
                out.println("</table>");

            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        <script type="text/javascript">
            $('#query-data').dataTable();
        </script>
    </div>
</div>
<div id="sparql" style="display:none;">
    <textarea  cols="100" rows="10"><%=query%></textarea><br/>
    <input type="button" value="Hide" onclick="$('#sparql').hide();
            $('#advance').show()"/>
</div>
<input id="advance" type="button" value="Advance" onclick="$('#sparql').show();
        $('#advance').hide()"/>

