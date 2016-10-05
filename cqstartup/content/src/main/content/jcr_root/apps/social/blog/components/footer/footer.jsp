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

  Blog: Footer component

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogManager,
                     com.day.cq.i18n.I18n,
                     com.day.cq.rewriter.linkchecker.LinkCheckerSettings" %>
<%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);

    out.flush();
    LinkCheckerSettings.fromRequest(slingRequest).setIgnoreExternals(true);

    I18n i18n = new I18n(slingRequest.getResourceBundle(currentPage.getLanguage(true)));

%><div id="footer">
    <p>
        <a href="<%= Blog.GENERATOR_URL %>" rel="generator"><%= Blog.GENERATOR_NAME %></a>
        <br />
        <a href="<%= xssAPI.getValidHref(blog.getFeedUrl(false)) %>" <%
            %>title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Atom Feed for entries '{0}'", "Do not translate Atom", blog.getTitle())) %>"><%
            %><%= i18n.get("Entries (Atom)", "Do not translate Atom") %></a> <%
        %><%= i18n.get("and") %>
        <a href="<%= xssAPI.getValidHref(currentPage.getContentResource().getPath()) %>.allcomments.feed" <%
            %>title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Atom Feed for comments in '{0}'", "Do not translate Atom", blog.getTitle())) %>"><%
        %><%= i18n.get("Comments (Atom)", "Do not translate Atom") %></a>
    </p>
</div><%

    out.flush();
    LinkCheckerSettings.fromRequest(slingRequest).setIgnoreExternals(false);

%>
