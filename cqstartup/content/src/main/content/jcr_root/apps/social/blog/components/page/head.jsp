<%--

 ADOBE CONFIDENTIAL
 __________________

  Copyright 2011 Adobe Systems Incorporated
  All Rights Reserved.

 NOTICE:  All information contained herein is, and remains
 the property of Adobe Systems Incorporated and its suppliers,
 if any.  The intellectual and technical concepts contained
 herein are proprietary to Adobe Systems Incorporated and its
 suppliers and are protected by trade secret or copyright law.
 Dissemination of this information or reproduction of this material
 is strictly forbidden unless prior written permission is obtained
 from Adobe Systems Incorporated.

  ==============================================================================

  Blog: Head script (included by page.jsp)

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogManager,
                     com.day.cq.i18n.I18n, java.util.ResourceBundle" %>
<%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);
    ResourceBundle bundle = slingRequest.getResourceBundle(currentPage.getLanguage(true));

%><head profile="http://gmpg.org/xfn/11">
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta http-equiv="keywords" content="<%= xssAPI.encodeForHTMLAttr(WCMUtils.getKeywords(currentPage)) %>">
    <meta name="generator" content="<%= Blog.GENERATOR_NAME %>">
    <title><%= blog.isEntry() ? xssAPI.filterHTML(blog.getEntry().getTitle()) + " &laquo; " : "" %><%= xssAPI.filterHTML(blog.getTitle()) %></title>
    <link rel="alternate" type="application/atom+xml" <%
        %>title="<%= xssAPI.encodeForHTMLAttr(I18n.get(bundle, "Atom Feed for '{0}'", null, blog.getTitle())) %>" <%
        %>href="<%= xssAPI.getValidHref(blog.getFeedUrl(false)) %>">
    <% currentDesign.writeCssIncludes(out); %>
    <cq:include script="headlibs.jsp"/>
    <cq:include script="init.jsp"/>
    <cq:include script="stats.jsp"/>
    <%
    if (blog.isEntry()) {
        String cssPath = currentDesign.getPath() + "/static_entry.css";
        if (resourceResolver.getResource(cssPath) != null) {
            %><link rel="stylesheet" href="<%= xssAPI.getValidHref(currentDesign.getPath()) %>/static_entry.css" type="text/css"><%
        }
    }
    %>
</head>
