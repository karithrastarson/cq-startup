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

  Creates a {com.day.cq.wcm.foundation.List} list from the request and sets
  it as a request attribute.

--%><%@ page session="false" pageEncoding="utf-8" import="com.adobe.cq.social.blog.AuthorEntryFilter,
                     com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogArchive,
                     com.adobe.cq.social.blog.BlogEntry,
                     com.adobe.cq.social.blog.BlogEntryDateComparator,
                     com.adobe.cq.social.blog.BlogEntryFilter,
                     com.adobe.cq.social.blog.BlogManager,
                     com.adobe.cq.social.blog.BlogSuffix,
                     com.adobe.cq.social.blog.DraftEntryFilter,
                     com.adobe.cq.social.blog.ParentPathEntryFilter,
                     com.adobe.cq.social.blog.TagEntryFilter,
                     com.day.cq.i18n.I18n,
                     com.day.cq.tagging.Tag,
                     com.day.cq.tagging.TagManager,
                     com.day.cq.wcm.foundation.List,
                     java.text.DateFormat,
                     java.text.SimpleDateFormat,
                     java.util.ArrayList,
                     java.util.Comparator,
                     java.net.URLDecoder" %>
<%
%><%@include file="/libs/foundation/global.jsp"%><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);
    String view = blogMgr.getView(request);

    I18n i18n = new I18n(slingRequest.getResourceBundle(currentPage.getLanguage(true)));

    List list = new List(slingRequest);
    list.setType("blog");

    // Get request suffix which may contain a filter on the blog
    BlogSuffix suffix = slingRequest.adaptTo(BlogSuffix.class);
    boolean hasSuffix = suffix != null;
    String suffixValue = hasSuffix ? suffix.getValue() : null;

    if (Blog.VIEW_SEARCH.equals(view) && request.getParameter(Blog.PARAM_QUERY) != null) {

        String query = request.getParameter(Blog.PARAM_QUERY);
        String[] queries = query.split("\\s+");
        String subXPathQuery = "";
        for (int i = 0; i <= queries.length - 1; i++) {
            if (i >= queries.length - 1) {
                subXPathQuery = subXPathQuery + "jcr:contains(., '" + xssAPI.encodeForJSString(queries[i]) + "')" ;
            } else {
                subXPathQuery = subXPathQuery + "jcr:contains(., '" + xssAPI.encodeForJSString(queries[i]) + "') or " ;
            }
         }
        String xPathQuery = "/jcr:root" + blog.getPage().getPath() +
                "/*[not(fn:name() = 'unlisted')]/*/element(*, cq:Page)["+ subXPathQuery + "]";
        list.setSource(List.SOURCE_SEARCH);
        list.setQuery(xPathQuery, "xpath");
        list.setOrderComparator(new Comparator<Page>() {
            BlogEntryDateComparator<BlogEntry> bec = new BlogEntryDateComparator<BlogEntry>();
            public int compare(Page page1, Page page2) {
                BlogEntry entry1 = page1.getContentResource().adaptTo(BlogEntry.class);
                BlogEntry entry2 = page2.getContentResource().adaptTo(BlogEntry.class);
                return bec.compare(entry1, entry2);
            }
        });
        %><h2 class="pagetitle"><%= xssAPI.encodeForHTML(i18n.get("Search results for '{0}'", null, query)) %></h2><%

    } else {

        java.util.List<Page> pages = new ArrayList<Page>();
        java.util.List<BlogEntry> entries;

        String period = currentPage.getProperties().get(Blog.PROP_BLOG_ARCHIVE, null);
        if (period != null ||
                (Blog.VIEW_ARCHIVE.equals(view) && request.getParameter(Blog.PARAM_PERIOD) != null)) {

            if (period == null) {
                period = request.getParameter(Blog.PARAM_PERIOD);
            }
            DateFormat monthDf = new SimpleDateFormat(i18n.get("MMMMM yyyy"));
            DateFormat yearDf = new SimpleDateFormat(i18n.get("yyyy", "yyyy is the year (ex: 2009). Should be translated 2009年 in Japanese."));
            String title = BlogArchive.getPeriodTitle(period, monthDf, yearDf);
            entries = blog.getEntries(new ParentPathEntryFilter(period));
            %><h2 class="pagetitle"><%= xssAPI.encodeForHTML(i18n.get("Archive for '{0}'", null, title)) %></h2><%

        } else if (hasSuffix && suffix.isA(BlogSuffix.CATEGORY)
                || (Blog.VIEW_TAG.equals(view) && request.getParameter(Blog.PARAM_TAG) != null)) {

            String tagPath = hasSuffix ? suffixValue : request.getParameter(Blog.PARAM_TAG);
            entries = blog.getEntries(new TagEntryFilter(tagPath));
            Tag tag = slingRequest.getResourceResolver().adaptTo(TagManager.class).resolve(tagPath);
            if (tag != null) {
                %><h2 class="pagetitle"><%= xssAPI.filterHTML(i18n.get("Entries filed under '{0}'", null, tag.getTitle())) %></h2><%
            } else {
                %><h2 class="pagetitle"><%= i18n.get("No such category found") %></h2><%
            }

        } else if (hasSuffix && suffix.isA(BlogSuffix.AUTHOR)
                || (Blog.VIEW_AUTHOR.equals(view) && request.getParameter(Blog.PARAM_AUTHOR) != null)) {

            String author = hasSuffix ? suffixValue : request.getParameter(Blog.PARAM_AUTHOR);
            entries = blog.getEntries(new AuthorEntryFilter(author));
            if (author != null) {
                %><h2 class="pagetitle"><%= xssAPI.encodeForHTML(i18n.get("Entries by {0}", null, URLDecoder.decode(author))) %></h2><%
            }

        } else {
            if (request.getParameterValues("blog_filter") != null) {
                java.util.List<BlogEntryFilter> filters = new ArrayList<BlogEntryFilter>();
                for (String filter : request.getParameterValues("blog_filter")) {
                    if (filter.equals("drafts")) {
                        filters.add(new DraftEntryFilter(true));
                    } else if (filter.equals("nondrafts")) {
                        filters.add(new DraftEntryFilter(false));
                    }
                }
                entries = blog.getEntries(filters);
            } else {
                entries = blog.getEntries();
            }

        }
        for (BlogEntry entry : entries) {
            pages.add(entry.getPage());
        }
        list.setPageIterator(pages.iterator());

    }

    request.setAttribute("list", list);

%>
