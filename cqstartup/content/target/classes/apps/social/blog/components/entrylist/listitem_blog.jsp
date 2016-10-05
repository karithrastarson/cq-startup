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

  List component sub-script

  Draws a list item as a teaser.

  request attributes:
  - {com.day.cq.wcm.foundation.List} list The list
  - {com.day.cq.wcm.api.Page} listitem The list item as a page

--%><%
%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.adobe.cq.social.blog.BlogManager,
                   com.day.cq.commons.date.DateUtil,
                   com.day.cq.i18n.I18n,
                   com.day.cq.tagging.Tag,
                   com.day.cq.wcm.api.components.IncludeOptions,
                   com.day.cq.wcm.api.WCMMode,
                   com.day.cq.wcm.foundation.Paragraph,
                   com.day.cq.wcm.foundation.ParagraphSystem,
                   java.text.DateFormat,
                   java.util.Locale,
                   java.util.ResourceBundle" %>
<%@include file="/libs/social/commons/commons.jsp"%><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    BlogEntry entry = blogMgr.getBlogEntry(slingRequest, ((Page)request.getAttribute("listitem")).getPath());
    String title = entry.getTitle();
    String text = entry.getText();
    ParagraphSystem parsys = entry.getContentResource() != null ?
            new ParagraphSystem(entry.getContentResource()) : null;

    DateFormat dateFormat = DateUtil.getDateFormat(properties.get("dateFormat", String.class), DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.SHORT, pageLocale), pageLocale);
    String date = entry.getDate() != null ? dateFormat.format(entry.getDate()) : "";

    String author = entry.getAuthor();
    String url = entry.getUrl();
    Tag[] tags = entry.getTags();

    int comments = entry.countComments();
%><div class="blogentry">
    <h2>
        <a href="<%= xssAPI.getValidHref(url) %>" <%
            %>rel="bookmark" <%
            %>title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Permanent link to '{0}'", null, title)) %>" <%
            %>onclick="blogSearchTrackClick('<%= xssAPI.encodeForJSString(title) %>')"<%
        %>><%= xssAPI.filterHTML(title) %></a>
    </h2>
    <small><%= date %><%
        if (!Blog.ANONYMOUS.equals(author)) {
            %> <%= xssAPI.encodeForHTML(i18n.get("by {0}", "Text inserted just before displaying the author of a blog entry", author)) %><%
        }
    %></small>
    <div class="entry">
        <div class="snap_preview"><%
            if (parsys == null) {
                %><%= xssAPI.filterHTML(text) %><%
            } else {
                for (Paragraph par : parsys.paragraphs()) {
                    if (par.getResourceType().endsWith("break")) {
                        %><a href="<%= xssAPI.getValidHref(url) %>" <%
                            %>title="<%= xssAPI.encodeForHTMLAttr(entry.getTitle()) %>" <%
                            %>onclick="blogSearchTrackClick('<%= xssAPI.encodeForJSString(entry.getTitle()) %>')"<%
                        %>><%= i18n.get("Read More", "Name of the link to jump to the full blog entry page") %> &raquo;</a><%
                        break;
                    }
                    IncludeOptions.getOptions(request, true).forceSameContext(true);
                    %><sling:include resource="<%= par %>"/><%
                }
            }
        %></div>
    </div>
    <p class="postmetadata"><%
        if (tags.length > 0) {
            %><%= xssAPI.filterHTML(i18n.get("Posted in {0} | ", null, entry.getTagsAsHTML(resourceBundle))) %>  <%
        }
        String editUrl = null;
        String user = loggedInUserName;
        if(user!=null && entry!=null && user.equals(author)){
            editUrl = entry.getEditUrl(slingRequest);
        }
        if ((WCMMode.fromRequest(slingRequest) != WCMMode.DISABLED) && (editUrl != null)) {
            %><a href="<%= xssAPI.getValidHref(editUrl) %>" <%
                %>title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Edit '{0}'", "Name of the link to edit a blog entry", title)) %>"<%
            %>><%= i18n.get("Edit") %></a> | <%
        }
        %><a href="<%= xssAPI.getValidHref(url) %>#comments" <%
            %>title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Comment on '{0}'", "Name of the link to view comments of a blog entry", title)) %>" <%
            %>onclick="blogSearchTrackClick('<%= xssAPI.encodeForJSString(title) %>')" <%
        %>><%
        if (comments == 0) {
            %><%= i18n.get("No comments yet") %><%
        } else {
            %><%= comments %> <%= comments == 1 ? i18n.get("Comment", "Number of comments (only one)") : i18n.get("Comments", "Number of comments (multiple)") %><%
        }
        %> &#187;</a>
    </p>
</div>
