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

  Blog: Head libs script (included by head.jsp)

  ==============================================================================

--%><%@ page session="false" import="com.day.text.Text,
                     com.day.cq.wcm.api.WCMMode" %><%
%><%@include file="/libs/foundation/global.jsp" %><%
    // Include Blog design client lib
    // This client library has to be defined under '/etc' repository path
    // and his category must be named "cq.social.blog.<design nome name>".
    // The 'embed' property will contain all client libraries that a blog
    // page using that design may need to run correctly on a publish instance.
    if (currentDesign != null) {
        String libCategory = "cq.social.blog." + Text.getName(currentDesign.getPath());
        if (WCMMode.fromRequest(request) == WCMMode.DISABLED) {
            // just include the themes and css
            %><cq:includeClientLib css="<%= xssAPI.encodeForHTMLAttr(libCategory) %>"/><%
            %><cq:includeClientLib theme="<%= xssAPI.encodeForHTMLAttr(libCategory) %>"/><%
        } else {
            %><cq:includeClientLib categories="<%= xssAPI.encodeForHTMLAttr(libCategory) %>"/><%
        }
    }
%>
