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

  Blog: Header script (included by body.jsp)

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogManager,
                     com.day.cq.rewriter.linkchecker.LinkCheckerSettings,
                     org.apache.commons.lang3.StringEscapeUtils" %><%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);

    out.flush();
    LinkCheckerSettings.fromRequest(slingRequest).setIgnoreExternals(true);

%><div id="header">
    <a href="<%= blog.getUrl() %>" title="<%= StringEscapeUtils.escapeHtml4(blog.getTitle()) %>">
        <div id="headerimg">
            <h1><%= StringEscapeUtils.escapeHtml4(blog.getTitle()) %></h1>
            <div class="description"><%= StringEscapeUtils.escapeHtml4(blog.getDescription()) %></div>
        </div>
    </a>
</div>
<hr/><%

    out.flush();
    LinkCheckerSettings.fromRequest(slingRequest).setIgnoreExternals(false);

%>
