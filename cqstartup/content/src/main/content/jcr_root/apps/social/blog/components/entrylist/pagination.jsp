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

--%><%@ page session="false" import="com.day.cq.i18n.I18n,
                 com.day.cq.wcm.foundation.List,
                 java.util.Locale,
                 com.adobe.cq.social.blog.Blog,
                 java.util.ResourceBundle" %><%
%><%@ include file="/libs/foundation/global.jsp"%><%

List list = (List)request.getAttribute("list");
Locale pageLocale = currentPage.getLanguage(true);
ResourceBundle resourceBundle = slingRequest.getResourceBundle(pageLocale);
I18n i18n = new I18n(resourceBundle);

String query = request.getParameter(Blog.PARAM_QUERY);
int blogSearchResults = list.size();
int blogPageNumber = 1 + (int)Math.floor((double)list.getPageStart() / (double)list.getPageMaximum());

%><div class="pagination"><%
    String previousPageLink = list.getPreviousPageLink();
    if (previousPageLink != null) {
        %><div class="previous"><%
            %><a href="<%= xssAPI.getValidHref(previousPageLink) %>" onclick="blogSearchTracPageClick('<%= blogPageNumber - 1 %>')">&laquo; <%= i18n.get("Newer Posts") %></a><%
        %></div><%
    }
    String nextPageLink = list.getNextPageLink();
    if (nextPageLink != null) {
        %><div class="next"><%
            %><a href="<%= xssAPI.getValidHref(nextPageLink) %>" onclick="blogSearchTrackPageClick('<%= blogPageNumber + 1 %>')"><%= i18n.get("Older Posts") %> &raquo;</a><%
        %></div><%
    }
%></div>

<script type="text/javascript">
   function blogSearchTrackPageClick(blogPageNumber) {

                CQ_Analytics.record({event: 'blogPageClicked',
                                     values: {
                                        'blogSearchKeyword': '<%= xssAPI.encodeForJSString(query) %>',
                                        'blogSearchResults': '<%= blogSearchResults %>',
                                        'blogPageNumber': blogPageNumber},
                                    componentPath: '<%=resource.getResourceType()%>'
                });
                return false;
            }
</script>
