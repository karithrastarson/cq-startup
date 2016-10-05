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

 Atom feed entry renderer for blog entries

 Draws the current blog entry as a feed entry.

--%><%@ page session="false" %><%
%><%@ page import="java.util.Date,
                   com.day.cq.tagging.Tag,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogManager,
                   com.day.cq.wcm.api.WCMMode"%><%
%><%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><%@ taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><%@ taglib prefix="atom" uri="http://sling.apache.org/taglibs/atom/1.0" %><%
%><%@ taglib prefix="media" uri="http://sling.apache.org/taglibs/mediarss/1.0" %><%
%><cq:defineObjects /><%

    try {
        WCMMode.DISABLED.toRequest(request);

        BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
        Blog blog = blogMgr.getBlog(slingRequest, resource.getPath());

        if (blog.isEntry()) {
            BlogEntry entry = blog.getEntry();
            String id = entry.getId();
            String link = entry.getFullUrl();
            String title = entry.getTitle();
            String author = entry.getAuthor();
            Date pdate = entry.getDate();
            Date udate = entry.getPage().getLastModified() != null ?
                    entry.getPage().getLastModified().getTime() :
                    entry.getPage().getProperties().get("jcr:lastModified", Date.class);
            Tag[] tags = entry.getTags();

            // NOTE WELL: atom: is a taglib, not generated output.  Don't be tempted to encode attribute
            // values.  (We may not even need to filter the HTML element content, but we currently do.)

            %><atom:entry
                    id="<%= id %>"
                    updated="<%= udate %>"
                    published="<%= pdate %>"><%
                %><atom:title><%= xssAPI.filterHTML(title) %></atom:title><%
                %><atom:author
                        name="<%= author %>"
                        email="noemail@noemail.org"/><% // todo: make configurable
                %><atom:link href="<%= link %>"/><%

                %><atom:content><%= xssAPI.filterHTML(entry.getText()) %></atom:content><%

                for (Tag tag : tags) {
                    %><atom:category term="<%= tag.getTitle() %>"/><%
                }

                // todo: list attachments as enclosures

            %></atom:entry><%
        }
    } catch (Exception e) {
        log.error("error while rendering feed entry for blog entry", e);
    }
%>