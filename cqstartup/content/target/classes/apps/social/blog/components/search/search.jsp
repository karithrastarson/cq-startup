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

  Blog: Search component

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogManager,
                     com.day.cq.i18n.I18n" %>
<%
%><%@include file="/libs/foundation/global.jsp" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);

    I18n i18n = new I18n(slingRequest.getResourceBundle(currentPage.getLanguage(true)));

%><li>
    <div>
        <form id="searchform" name="searchform" method="get" action="<%= xssAPI.getValidHref(blog.getUrl()) %>">

            <input type="text" id="livesearch" name="<%= Blog.PARAM_QUERY %>" value="<%= i18n.get("search this site") %>" onblur="this.value=(this.value=='') ? '<%= i18n.get("search this site") %>' : this.value;" onfocus="this.value=(this.value=='<%= i18n.get("search this site") %>') ? '' : this.value;" />
            <input type="hidden" name="<%= Blog.PARAM_VIEW %>" value="<%= Blog.VIEW_SEARCH %>"/>
            <input type="hidden" name="_charset_" value="<%= request.getCharacterEncoding() %>"/>
            <input type="submit" id="searchsubmit" style="display: none;" value="<%= i18n.get("Search") %>" />
        </form>
    </div>
</li>
