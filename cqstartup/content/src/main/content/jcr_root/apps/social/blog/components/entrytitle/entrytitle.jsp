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

  Title component.

  Draws a title either store on the resource or from the page

--%><%@include file="/libs/foundation/global.jsp"%><%
%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.day.cq.i18n.I18n,
                   java.util.ResourceBundle" %>
<%
    ResourceBundle bundle = slingRequest.getResourceBundle(currentPage.getLanguage(true));
    BlogEntry entry = resource.adaptTo(BlogEntry.class);
    %><div class="entrytitle_wrap"><h2><%= xssAPI.filterHTML(entry.getTitle()) %></h2></div><%

    if (!Blog.ANONYMOUS.equals(entry.getAuthor()) && !entry.isPage()) {
       %><small><%= xssAPI.encodeForHTML(I18n.get(bundle, "By {0}", "Used to display a blog entry's author", entry.getAuthor())) %></small><%
    }
%>
