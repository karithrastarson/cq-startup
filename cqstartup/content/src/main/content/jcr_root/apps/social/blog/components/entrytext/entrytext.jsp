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

  Blog: Entry component

  ==============================================================================

--%><%@ page session="false" import="com.adobe.cq.social.blog.Blog,
                   com.adobe.cq.social.blog.BlogEntry,
                   com.adobe.cq.social.blog.BlogManager,
                   com.day.cq.wcm.api.WCMMode,
                   java.security.AccessControlException" %><%
%><%@include file="/libs/foundation/global.jsp" %><%


    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    BlogEntry entry = resource.adaptTo(BlogEntry.class);

    String text = entry.getText();

    if ("".equals(text) && WCMMode.fromRequest(request) == WCMMode.EDIT) {
        %><img src="/libs/cq/ui/resources/0.gif" class="cq-text-placeholder" alt=""><%
    }

    %><%= xssAPI.filterHTML(text) %><%

    if (Blog.VIEW_EDIT.equals(blogMgr.getView(request)) &&
            WCMMode.fromRequest(request) == WCMMode.EDIT) {

        // only allow editing if user has sufficient permissions
        try {
            Session session = slingRequest.getResourceResolver().adaptTo(Session.class);
            session.checkPermission(currentPage.getPath(), "set_property");

            %><script type="text/javascript">
           CQ.WCM.onEditableReady("<%= xssAPI.encodeForJSString(currentPage.getContentResource(BlogEntry.NODE_TEXT).getPath()) %>",
                function(editable) {
                    CQ.wcm.EditBase.showDialog(editable, CQ.wcm.EditBase.EDIT);
                }
            );
            </script><%
        } catch (AccessControlException ace) {
            // todo: handle insufficient permissions
        }

    }
%>
