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

  Blog: Entry component sub-script

  Renders the entry for feeds.

  ==============================================================================

--%><%!

%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.adobe.cq.social.blog.BlogManager" %><%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);
    if (blog.isEntry()) {
        BlogEntry entry = blog.getEntry();
        %><%= xssAPI.filterHTML(entry.getText()) %><%
    }

%>
