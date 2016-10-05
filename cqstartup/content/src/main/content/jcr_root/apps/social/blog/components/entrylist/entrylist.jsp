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

  Blog: Entry List component (extends List component)

--%><%@ page session="false" import="com.day.cq.wcm.foundation.List,
                     com.adobe.cq.social.blog.Blog"
%><%@include file="/libs/foundation/global.jsp"%><%
%><cq:include script="/libs/foundation/components/list/list.jsp"/><%

List list = (List)request.getAttribute("list");
String query = request.getParameter(Blog.PARAM_QUERY);
int blogSearchResults = list.size();
int blogPageNumber = 1 + (int)Math.floor((double)list.getPageStart() / (double)list.getPageMaximum());
if (query != null && blogSearchResults > 0) {
    %><span data-tracking="{event:'blogSearch', values:{<%
        %>'blogSearchKeyword': '<%= xssAPI.encodeForJSString(query) %>', <%
        %>'blogSearchResults': '<%= blogSearchResults %>', <%
        %>'blogPageNumber': '<%= blogPageNumber %>'<%
    %>}, componentPath:'<%=resource.getResourceType()%>'}"></span><%
}
%>

<script type="text/javascript">

   function blogSearchTrackClick(blogSearchSelectionTitle) {

                CQ_Analytics.record({event: 'blogSearchSelection',
                                     values: {
                                        'blogSearchKeyword': '<%= xssAPI.encodeForJSString(query) %>',
                                        'blogSearchResults': '<%= blogSearchResults %>',
                                        'blogPageNumber': '<%= blogPageNumber %>',
                                        'blogSearchSelectionTitle': blogSearchSelectionTitle },
                                     componentPath: '<%=resource.getResourceType()%>'
                });

                return false;
            }
</script>
