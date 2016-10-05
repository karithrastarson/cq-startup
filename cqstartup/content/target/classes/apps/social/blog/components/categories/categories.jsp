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

  Blog: Categories component

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogManager,
                     com.day.cq.i18n.I18n,
                     com.day.cq.tagging.Tag,
                     java.util.ResourceBundle" %>
<%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);
    ResourceBundle resourceBundle = slingRequest.getResourceBundle(currentPage.getLanguage(true));

    %><li class="categories">
        <h2><%= I18n.get(resourceBundle, "Categories") %></h2>
        <%
        Tag[] tags = blog.getTags();
        if (tags.length > 0) {
            %><%= xssAPI.filterHTML(blog.getTagsAsHTML(resourceBundle)) %><%
        }
        %>
    </li>
