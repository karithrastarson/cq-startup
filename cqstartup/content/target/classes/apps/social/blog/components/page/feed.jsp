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

  Atom feed renderer for blog and blog entry nodes

  - Draws the current blog as a feed, listing its blog entries as feed entries
  - Draws the current blog entry as a feed, listing its comments as feed entries

--%><%@ page session="false" %><%
%><%@ page import="java.util.List,
                   java.util.ArrayList,
                   java.util.Collections,
                   com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogManager,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.adobe.cq.social.blog.BlogEntryFilter,
                   com.adobe.cq.social.blog.TagEntryFilter,
                   com.adobe.cq.social.blog.AuthorEntryFilter,
                   com.adobe.cq.social.commons.Comment,
                   com.day.cq.commons.ProductInfoService,
                   com.day.cq.commons.ProductInfo,
                   com.day.cq.wcm.api.WCMMode,
                   org.apache.sling.api.resource.Resource,
                   org.apache.sling.api.resource.ResourceResolver,
                   java.util.Iterator,
                   org.apache.sling.api.resource.ValueMap,
                   com.day.cq.wcm.api.components.ComponentContext"%><%
%><%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><%@ taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %><%
%><%@ taglib prefix="atom" uri="http://sling.apache.org/taglibs/atom/1.0" %><%
%><cq:defineObjects /><%!
    /**
     * Descends the resource hierarchy until a blog entry list component is found,
     * then the value of the limit property is returned.
     * @param res The resource
     * @return The limit
     */
    protected static int findLimit(Resource res) {
        int limit = -1;
        ResourceResolver rr = res.getResourceResolver();
        try {
            Iterator<Resource> children = rr.listChildren(res);
            while (children.hasNext()) {
                Resource child = children.next();
                if (child.getResourceType().equals("social/blog/components/entrylist")) {
                    limit = child.adaptTo(ValueMap.class).get("limit", -1);
                    break;
                }
                limit = findLimit(child);
            }
        } catch (Exception e) {}
        return limit;
    }

%><%

    try {
        ProductInfo pi = sling.getService(ProductInfoService.class).getInfo();
        WCMMode.DISABLED.toRequest(request);

        String tag = request.getParameter(Blog.PARAM_TAG);
        String author = request.getParameter(Blog.PARAM_AUTHOR);

        BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
        Blog blog = blogMgr.getBlog(slingRequest, resource.getPath());
        BlogEntry entry = blog.getEntry();

        String url = blog.getFullUrl();

        String feedUrl = blog.isEntry() ? entry.getFeedUrl(true) : blog.getFeedUrl(true);
        String link = blog.isEntry() ? entry.getFullUrl() : blog.getFullUrl();
        String title = blog.isEntry() ? entry.getTitle() : blog.getTitle();
        String subTitle = blog.isEntry() ? entry.getAuthor() : blog.getDescription();
        String genUri = pi.getUrl();
        String genName = pi.getName();
        String genVersion = pi.getShortVersion();
        int limit = findLimit(resource);
        request.setAttribute(ComponentContext.BYPASS_COMPONENT_HANDLING_ON_INCLUDE_ATTRIBUTE, true);

        // NOTE WELL: atom: is a taglib, not generated output.  Don't be tempted to encode attribute
        // values.  (We may not even need to filter the HTML element content, but we currently do.)

        %><atom:feed id="<%= url %>"><%
            %><atom:title><%= xssAPI.filterHTML(title) %></atom:title><%
            if (!"".equals(subTitle)) {
                %><atom:subtitle><%= xssAPI.filterHTML(subTitle) %></atom:subtitle><%
            }
        %><atom:link href="<%= feedUrl %>" rel="self"/><%
        %><atom:link href="<%= link %>"/><%
        %><atom:generator uri="<%= genUri %>" version="<%= genVersion %>"><%= xssAPI.filterHTML(genName) %></atom:generator><%

        if (blog.isEntry()) {
            // blog entry: list comments
            if (entry.hasComments()) {
              for (final Iterator<Comment> commentIterator = entry.getComments(); commentIterator.hasNext();) {
                  Comment comment = commentIterator.next();
                  String path = comment.getPath() + ".feedentry";
                  %><sling:include path="<%= path %>"/><%
                }
            }
        } else {
            int count = 1;
            // blog: list blog entries
            List<BlogEntry> entries;
            if (tag != null || author != null) {
                List<BlogEntryFilter> filters = new ArrayList<BlogEntryFilter>();
                if (tag != null) {
                    filters.add(new TagEntryFilter(tag));
                }
                if (author != null) {
                    filters.add(new AuthorEntryFilter(author));
                }
                entries = blog.getEntries(filters);
            } else {
                entries = blog.getEntries();
            }
            for (BlogEntry child : entries) {
                String path = child.getPage().getContentResource().getPath() + ".feedentry";
                %><sling:include path="<%= path %>"/><%
                if (limit > 0 && count == limit) {
                    break;
                }
                count++;
            }
        }

        %></atom:feed><%

    } catch (Exception e) {
        log.error("error rendering feed for blog", e);
    }
%>