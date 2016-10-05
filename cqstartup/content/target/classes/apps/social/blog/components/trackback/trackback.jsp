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

  Renders the trackbacks to a blog post

--%><%@ page session="false" import="com.adobe.cq.social.commons.CommentSystem,
                     com.day.cq.commons.jcr.JcrConstants,
                     com.day.cq.i18n.I18n,
                     com.day.text.Text" %>
<%
%><%@include file="/libs/foundation/global.jsp"%><%

String name = Text.getName(resource.getPath());
String trackbacksPath = CommentSystem.PATH_UGC + currentPage.getPath() + "/" +
        JcrConstants.JCR_CONTENT + "/" + name;
Resource trackbacksResource = resource.getResourceResolver().getResource(trackbacksPath);
boolean hasTrackbacks = trackbacksResource != null;

%>



<div id="<%= xssAPI.encodeForHTMLAttr(name) %>">

<% if(hasTrackbacks) { %>
<div class="comments-count"><%= I18n.get(slingRequest.getResourceBundle(currentPage.getLanguage(true)), "Trackbacks") %></div>

<%

Node t = trackbacksResource.adaptTo(Node.class);
NodeIterator ni = t.getNodes();

while (ni.hasNext()) {
    Node tb = ni.nextNode();
    %><div><%

    if(tb.hasProperty("jcr:title") && tb.getProperty("jcr:title").getString().length() > 0) {
        %><a href="<%= xssAPI.getValidHref(tb.getProperty("url").getString()) %>"><%= xssAPI.filterHTML(tb.getProperty("jcr:title").getString()) %></a><%
    } else {
        %><a href="<%= xssAPI.getValidHref(tb.getProperty("url").getString()) %>"><%= xssAPI.encodeForHTML(tb.getProperty("url").getString()) %></a><%
    }

    if(tb.hasProperty("excerpt") && tb.getProperty("excerpt").getString().length() > 0) {
        %><div><%= xssAPI.filterHTML(tb.getProperty("excerpt").getString()) %></div><%
    }

    %></div><%
}

%>


<% } %>

</div>
