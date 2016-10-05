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

  Atom feed renderer for all blog comments

  - Draws the current blog as a feed, listing its blog entries as feed entries
  - Draws the current blog entry as a feed, listing its comments as feed entries

--%><%@ page session="false" %><%
%><%@ page import="com.adobe.cq.social.blog.BlogManager,
                   com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.adobe.cq.social.commons.CommentSystem,
                   com.adobe.cq.social.commons.Comment,
                   com.day.cq.commons.ProductInfo,
                   com.day.cq.commons.ProductInfoService,
                   java.util.List,
                   java.util.ArrayList,
                   java.util.Collections,
                   java.util.Comparator,
                   java.util.Iterator,
                   com.day.cq.wcm.api.components.ComponentContext" %><%
%><%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><%@ taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %><%
%><%@ taglib prefix="atom" uri="http://sling.apache.org/taglibs/atom/1.0" %><%
%><cq:defineObjects /><%

    try {
        BlogManager blogMgr = resourceResolver.adaptTo(BlogManager.class);
        Blog blog = blogMgr.getBlog(slingRequest);

        ProductInfoService pis = sling.getService(ProductInfoService.class);
        ProductInfo pi = pis.getInfo();
        String genUri = pi.getUrl();
        String genName = pi.getName();
        String genVersion = pi.getShortVersion();

        request.setAttribute(ComponentContext.BYPASS_COMPONENT_HANDLING_ON_INCLUDE_ATTRIBUTE, true);
        // gather comments from blog entries
        List<Comment> allComments = new ArrayList<Comment>();
        for (BlogEntry entry : blog.getEntries()) {
            for (final Iterator<Comment> commentIterator = entry.getComments(); commentIterator.hasNext();) {
              allComments.add(commentIterator.next());
            }

        }
        // and sort them by date
        Collections.sort(allComments, new Comparator<Comment>() {
            public int compare(Comment a, Comment b) {
                long aTime = a.getDate().getTime();
                long bTime = b.getDate().getTime();
                if(aTime > bTime) {
                    return 1;
                } else if(aTime < bTime) {
                    return -1;
                }
                return 0;
            }
        });

        // NOTE WELL: atom: is a taglib, not generated output.  Don't be tempted to encode attribute
        // values.  (We may not even need to filter the HTML element content, but we currently do.)

        %><atom:feed id="<%= blog.getFullUrl() %>"><%
            %><atom:title>Comments for <%= xssAPI.filterHTML(blog.getTitle()) %></atom:title><%
            if (!"".equals(blog.getDescription())) {
                %><atom:subtitle><%= xssAPI.filterHTML(blog.getDescription()) %></atom:subtitle><%
            }
        %><atom:link href="<%= blog.getFullUrl() %>" rel="self"/><%
        %><atom:generator uri="<%= genUri %>" version="<%= genVersion %>"><%= xssAPI.filterHTML(genName) %></atom:generator><%

        for (Comment comment : allComments) {
            try {
                if (comment.isSpam()) {
                    continue;
                }
                CommentSystem cs = comment.getCommentSystem();
                if (cs.isModerated() && !comment.isApproved()) {
                    continue;
                }
                BlogEntry entry = resourceResolver.getResource(cs.getPath()).adaptTo(BlogEntry.class);
                %><atom:entry
                        id="<%= comment.getFullUrl(slingRequest) %>"
                        updated="<%= comment.getDate() %>"
                        published="<%= comment.getDate() %>"><%
                    %><atom:title>Comment on <%= xssAPI.filterHTML(entry.getTitle()) %></atom:title><%
                    %><atom:author
                            name="<%= comment.getAuthor().getName() %>"
                            email="noemail@noemail.org"/><% // todo: make configurable
                    %><atom:link href="<%= comment.getFullUrl(slingRequest) %>"/><%
                    %><atom:content><%= xssAPI.filterHTML(comment.getMessage()) %></atom:content><%
                %></atom:entry><%
            } catch (Exception ex) {
                log.error("error rendering feed for comment " + comment.getPath());
            }
        }

        %></atom:feed><%

    } catch (Exception e) {
        log.error("error rendering feed for all blog comments", e);
    }
%>
