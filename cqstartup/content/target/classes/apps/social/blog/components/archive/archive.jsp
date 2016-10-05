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

  Blog: Archive component

  ==============================================================================

--%>
<%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                 com.adobe.cq.social.blog.BlogManager,
                 com.day.cq.commons.date.DateUtil,
                 com.day.cq.i18n.I18n,
                 java.util.Locale,
                 java.util.ResourceBundle, java.text.DateFormat" %>
<%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);

    Locale pageLocale = currentPage.getLanguage(true);
    ResourceBundle resourceBundle = slingRequest.getResourceBundle(pageLocale);
    DateFormat dateFormat = DateUtil.getDateFormat(properties.get("dateFormat", String.class), "yyyy MMMMM", pageLocale);

%><li>
    <h2><%= I18n.get(resourceBundle, "Archives") %></h2>
    <%= xssAPI.filterHTML(blog.getArchiveAsHTML(0, dateFormat, resourceBundle)) %>
</li>
