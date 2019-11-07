<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%
    String lang = "es";
%>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>VisualSearch</title>

        <link rel="stylesheet" href="visualsearch/visualsearch.css" type="text/css" media="screen" charset="utf-8">

            <script src="visualsearch/dependencies.js" type="text/javascript" charset="utf-8"></script>
            <script src="visualsearch/visualsearch.js" type="text/javascript" charset="utf-8"></script>

            <script src="visualsearch/jquery.dataTables.min.js"></script>
            <link rel="stylesheet" href="visualsearch/jquery.dataTables.css">  
            
            <style type="text/css">
                table.gridtable {
                    font-family: verdana,arial,sans-serif;
                    font-size:11px;
                    color:#333333;
                    border-width: 1px;
                    border-color: #666666;
                    border-collapse: collapse;
                }
                table.gridtable th {
                    border-width: 1px;
                    padding: 8px;
                    border-style: solid;
                    border-color: #666666;
                    background-color: #dedede;
                }
                table.gridtable td {
                    border-width: 1px;
                    padding: 8px;
                    border-style: solid;
                    border-color: #666666;
                    background-color: #ffffff;
                }
            </style>

    </head>

    <body>

        <div class="body_wrapper">

            <div class="wrapper_content" style="background: none; margin: 10px; margin-top: 20px">

                <div class="container" id="VS">

                    <div id="search_box_container"></div>
                    <div id="search_query">&nbsp;</div>

                    <script type="text/javascript" charset="utf-8">
                        var visualSearch;

                        $(document).ready(function() {
                            visualSearch = VS.init({
                                container: $('#search_box_container'),
                                query: '',
                                minLength: 0,
                                showFacets: true,
                                readOnly: false,
                                unquotable: [
                                    'text',
                                    'account',
                                    'filter',
                                    'access'
                                ],
                                placeholder: "Realiza tu búqueda...",
                                callbacks: {
                                    search: function(query, searchCollection)
                                    {
                                        var $query = $('#search_query');

                                        var q = visualSearch.getQuery(true);
                                        var r = visualSearch.getHtml("visualquery.jsp", JSON.stringify(q));
                                        $query.html(r);
                                        //$query.html('<span class="raquo">&raquo;</span> You searched for: <b>' + searchCollection.serialize() + '</b>');
                                    },
                                    valueMatches: function(category, searchTerm, callback)
                                    {
                                        //console.log("valueMatches:"+category+" :"+searchTerm); 
                                        var q = visualSearch.getQuery();
                                        //console.log(q);                

                                        callback(visualSearch.getJson("visualservice.jsp?t=" + category + "&s=" + searchTerm, JSON.stringify(q)));
                                    },
                                    facetMatches: function(callback, searchTerm, lastWord)
                                    {
                                        //console.log("facetMatches:"+searchTerm+":"+lastWord);
                                        //console.log("position:"+visualSearch.options.position);

                                        var q = visualSearch.getQuery();
                                        //console.log(q);

                                        callback(visualSearch.getJson("visualservice.jsp?s=" + searchTerm, JSON.stringify(q)),
                                                {
                                                    preserveOrder: true
                                                });
                                    }
                                }
                            });
                            visualSearch.clazz = new Array();

                            visualSearch._lgetJson = {url: null, json: null};                 //cache JSON

                            visualSearch.getJson = function(url, data)
                            {
                                if ((url + data) == this._lgetJson.url)
                                    return this._lgetJson.json;
                                console.log("getJson:" + url);
                                var ret = $.ajax({
                                    type: "POST",
                                    url: url,
                                    data: data,
                                    async: false
                                });
                                this._lgetJson.url = (url + data);
                                this._lgetJson.json = ret.responseJSON;
                                return this._lgetJson.json;
                            };

                            visualSearch.getHtml = function(url, data)
                            {
                                console.log("getHtml:" + url);
                                var ret = $.ajax({
                                    type: "POST",
                                    url: url,
                                    data: data,
                                    async: false
                                });
                                return ret.responseText;
                            };

                            visualSearch.getName = function(cat, value, select)
                            {
                                var sub = cat;
                                if (cat == "cls")
                                {
                                    sub = value;
                                } else
                                {
                                    if (!select && value.length > 0 && value.charAt(0) != '?')
                                    {
                                        sub = cat;
                                    }
                                    if (select && value.length > 1 && value.charAt(0) != '?')
                                    {
                                        sub = value;
                                    }
                                    if (value.length > 1 && value.charAt(0) == '?')
                                    {
                                        return value;
                                    }
                                }
                                if (sub.length == 0)
                                    return sub;

                                sub = sub.substring(sub.indexOf(":") + 1);

                                if (!visualSearch.clazz[sub]) {
                                    visualSearch.clazz[sub] = 1;
                                    _sub = sub + 1;
                                }
                                else {
                                    if (cat == "cls")
                                    {
                                        _sub = sub + (visualSearch.clazz[sub]);
                                    } else
                                    {
                                        _sub = sub + (++visualSearch.clazz[sub]);
                                    }
                                }
                                return "?" + _sub;
                            };

                            visualSearch.getQuery = function(name)
                            {
                                var q = [];
                                for (i = 0; i < visualSearch.options.position; i++)
                                {
                                    if (name)
                                    {
                                        q.push({category: visualSearch.searchQuery.models[i].get("category"), value: visualSearch.searchQuery.models[i].get("value"), name: visualSearch.searchQuery.models[i].get("name")});
                                    } else
                                    {
                                        q.push({category: visualSearch.searchQuery.models[i].get("category"), value: visualSearch.searchQuery.models[i].get("value")});
                                    }
                                }
                                return q;
                            }

                        });
                    </script>

                </div>            

            </div>

        </div>

    </body>
</html>
