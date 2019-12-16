<%-- 
    Document   : prog_menu
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataMgr"%><%@page import="org.semanticwb.datamanager.SWBScriptEngine"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String contextPath = request.getContextPath();     
    String _title="DataProperties";
    String _ds="DataSourceFields";
    String _fileName="prog_dp";
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    //if(!eng.hasUserPermission(_permision))response.sendError(403,"Acceso Restringido...");
    
    boolean iframe=request.getParameter("iframe")!=null; 
    
    if(!iframe)
    {
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Programación</li>
        <li class="active"><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
    </ol>
</section>
<!-- Main content -->
<%
        {
%>
<section id="content" style="padding: 7px">  
    <iframe class="ifram_content" src="<%=_fileName%>?iframe=true" frameborder="0" width="100%">Cargando...</iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>                        
</section><!-- /.content -->
<%
        }
    }else 
    {
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
        <script type="text/javascript">
            eng.initPlatform("/admin/ds/admin.js", <%=eng.getDSCache()%>);
        </script>
        <script type="text/javascript">            
            var grid=eng.createGrid({
                //gridType: "TreeGrid",
                autoResize: true,
                resizeHeightMargin: 20,
                resizeWidthMargin: 15,
                canEdit: true,
                showFilter: true,
                canAdd: true,
                canRemove: true,
                //canReorderRecords: true,
                //canAcceptDroppedRecords: true,
                
                expansionFieldImageShowSelected:true,
                canExpandRecords: true,                
                //sortField: "ds",       
                canMultiSort: true,
                initialSort: [
                    {property: "ds", direction: "ascending"},
                    {property: "order", direction: "ascending"}
                ],
    
                fields: [
                    {name: "ds"},
                    {name: "name"},
                    {name: "title"},
                    {name: "type"},        
                    {name: "length", width:100},        
                    {name: "description", length: 500},        
                    {name: "example"},        
                    {name: "required"},
                    {name: "order", width:70},
                ],
                getExpansionComponent : function (record) 
                {
                    var grd=eng.createGrid({
                        height:200,       
                        canEdit: true,
                        canAdd: true,
                        canRemove: true,
                        showFilter: false,
                        editByCell: true,
                        initialCriteria: {"dsfield":record._id},
                        fields: [
                            //{name: "dsfield"},
                            {name: "att"},
                            {name: "type"},
                            {name: "value"},
                        ],
                        getEditorProperties:function(editField, editedRecord, rowNum) {
                            //console.log("getEditorProperties",this,this.getSelectedRecord().type,editField,editedRecord,rowNum);
                            if (editField.name == "value")
                            {
                                if(editedRecord!=null) {
                                    var item=ds_field_atts_vals[editedRecord.att];                                     
                                    var act=this.getSelectedRecord();
                                    if(act)
                                    {
                                        if(item.type!=act.type)
                                        {
                                            item.type=act.type;
                                        }
                                    }                                    
                                    editField._lastItem=item;
                                    //console.log(item);                                    
                                    return item;
                                }else
                                {
                                    return editField._lastItem;
                                }
                            } 
                            return {};
                        },                        
                    }, "<%=_ds%>Ext");  
                    return grd;
                }                        
                
            }, "<%=_ds%>");    
        </script>         
    </body>
</html>
<%
    }
%>