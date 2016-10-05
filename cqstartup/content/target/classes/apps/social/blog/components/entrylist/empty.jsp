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

  Blog: List component sub-script override

--%><%@ page session="false" import="com.day.cq.i18n.I18n,
                     com.adobe.cq.social.blog.Blog" %>
<%
%><%@include file="/libs/foundation/global.jsp"%><%
    String query = request.getParameter(Blog.PARAM_QUERY);
%><h3 class="pagetitle"><%= I18n.get(slingRequest.getResourceBundle(currentPage.getLanguage(true)), "No entries found") %></h3>
<span data-tracking="{event:'blogSearchNoresults', values:{'blogSearchKeyword': '<%= xssAPI.encodeForJSString(query) %>', 'blogSearchResults':'zero'}, componentPath:'<%=resource.getResourceType()%>'}"></span>
