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

  Blog: Footer component

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                     com.adobe.cq.social.blog.BlogEntry,
                     com.day.cq.commons.date.DateUtil,
                     com.day.cq.i18n.I18n,
                     com.day.cq.tagging.Tag,
                     com.adobe.cq.social.commons.Comment,
                     org.apache.sling.api.resource.Resource,
                     java.text.DateFormat,
                     java.util.Locale,
                     java.util.Iterator,
                     java.util.ResourceBundle" %>
<%@include file="/libs/social/commons/commons.jsp"%><%

    BlogEntry entry = resource.adaptTo(BlogEntry.class);
    Tag[] tags = entry.getTags();
    Iterator<Comment> comments = entry.getComments();
    Comment comment = null;
    while (comments.hasNext())
        comment = comments.next();

    String editUrl = null;
    String user = loggedInUserName;
    Blog blog = entry.getBlog();
    if(user!=null && entry!=null && user.equals(entry.getAuthor())){
        //replace with blog edit form
        editUrl = entry.getEditUrl(slingRequest);
        String formUrl = blog.getPage().getProperties().get("editForm", String.class);
        if(formUrl == null || formUrl==""){
            formUrl = blog.getUrl().replace(".html", "/editblogform");
        }
        //editUrl = entry.getUrl();
        //editUrl = editUrl.replace(".html", ".form.html" + formUrl);
    }

    String entryType = entry.isPage() ? i18n.get("page") : i18n.get("entry");

%><p class="postmetadata alt">
<small>
    <%
    if (!entry.isPage()) {
        // Get date format specific to the page
        DateFormat dateFormat = DateUtil.getDateFormat(currentPage.getProperties().get("dateFormat", String.class), pageLocale);
        if (dateFormat == null) {
            dateFormat = DateUtil.getDateFormat(blog.getPage().getProperties().get("dateFormat", String.class), "E MMM dd HH:mm:ss zz yyyy", pageLocale);
        }
        String tagStr = tags.length > 0 ? i18n.get(" and filed under {0}", null, xssAPI.filterHTML(entry.getTagsAsHTML(resourceBundle))) : "";
        String atomLink = "<a href=\"" + xssAPI.getValidHref(entry.getFeedUrl(false)) + "\" title=\"" + xssAPI.encodeForHTMLAttr(i18n.get("Atom Feed for blog entry '{0}'", null, entry.getTitle())) + "\">Atom</a>";
        String responseLink = "<a href=\"#comments\" title=\"" + xssAPI.encodeForHTMLAttr(i18n.get("Reply to blog entry '{0}'", null, entry.getTitle())) + "\">" + i18n.get("leave a response") + "</a>";
        String trackbackLink = "<a href=\"" + xssAPI.getValidHref(entry.getTrackBackUrl()) + "\" rel=\"trackback\" title=\"" + xssAPI.encodeForHTMLAttr(i18n.get("Trackback URL for blog entry '{0}'", null, entry.getTitle())) + "\">" + i18n.get("trackback") + "</a>";
        %><%= i18n.get("This entry was posted on {0}{1}. You can follow any responses to this entry through the {2} feed. You can {3}, or {4} from your own site.",
                                        null, dateFormat.format(entry.getDate()), tagStr, atomLink, responseLink, trackbackLink) %><%
    }
    if (editUrl != null) {
        %> <a href="<%= xssAPI.getValidHref(editUrl) %>" title="<%= i18n.get("Edit Entry") %>"><%= i18n.get("Edit this {0}.", "Name of the link used to edit a page or an entry", entryType) %></a><%
    }
    %>
</small>
</p>

<span data-tracking="{event:'blogEntryView', values:{'blogEntryContentType': 'blog',
                                'blogEntryUniqueID': '<%= xssAPI.encodeForJSString(entry.getId()) %>',
                                'blogEntryTitle': '<%= xssAPI.encodeForJSString(entry.getTitle()) %>',
                                'blogEntryAuthor':'<%= xssAPI.encodeForJSString(entry.getAuthor()) %>',
                                'blogEntryAddDate':'<%= entry.getDate() %>',
                                'blogEntryModificationDate':'<%= (comment != null ? comment.getDate() : entry.getDate()) %>',
                                'blogEntryComentsCount':'<%= entry.countComments() %>',
                                'blogEntryTags':'<%= xssAPI.encodeForJSString(entry.getTagsAsString()) %>',
                                'blogEntryPath':'<%= xssAPI.encodeForJSString(resource.getPath()) %>',
                                'blogEntryPageLanguage':'<%= currentPage.getLanguage(true) %>'}, componentPath:'<%=resource.getResourceType()%>'}">
</span>
