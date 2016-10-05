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

  Blog init script (copy from /libs/wcm/core/components/init/init.jsp).

  Draws the blog initialization code. This is called by the head.jsp
  of the page. If the WCM is disabled, no output is written.

  ==============================================================================

--%><%@include file="/libs/foundation/global.jsp" %><%
%><%@page session="false" import="com.adobe.cq.social.blog.Blog,
                  com.adobe.cq.social.blog.BlogManager,
                  com.day.cq.replication.ReplicationActionType,
                  com.day.cq.wcm.api.WCMMode" %><%

    BlogManager blogMgr = resource.getResourceResolver().adaptTo(BlogManager.class);
    Blog blog = blogMgr.getBlog(slingRequest);

if (WCMMode.fromRequest(request) != WCMMode.DISABLED) {
    String dlgPath = null;
    if (editContext != null && editContext.getComponent() != null) {
        dlgPath = editContext.getComponent().getDialogPath();
    }
    if (blog.isEntry()) {
        // use different page properties dialog for blog entry
        dlgPath += "_entry";
    }
    %><cq:includeClientLib categories="cq.wcm.edit, cq.tagging, cq.security"/>
    <script type="text/javascript" >
        CQ.WCM.launchSidekick("<%= xssAPI.encodeForJSString(currentPage.getPath()) %>", {
            <%
            if (blog.isEntry()) {
                %>
                actions:[
                    CQ.wcm.Sidekick.PROPS,
                    CQ.wcm.Sidekick.DELETE,
                    {
                        text: CQ.I18n.getMessage("Activate Blog Entry"),
                        handler: function() {
                            var path = this.path;
                            var paths = [];
                            var i = 0;
                            while (i < 3) {
                                paths.push(path);
                                path = path.substring(0, path.lastIndexOf("/"));
                                i++;
                            }
                            var response;
                            while (paths.length > 0) {
                                var toActivate = paths.pop();
                                if (paths.length != 0) {
                                    var data = CQ.HTTP.eval(toActivate + "/jcr:content.1" + CQ.HTTP.EXTENSION_JSON);
                                    if (toActivate != path &&
                                            data["<%= NameConstants.PN_PAGE_LAST_REPLICATION_ACTION %>"] == "<%= ReplicationActionType.ACTIVATE.getName() %>") {
                                        continue;
                                    }
                                }
                                response = CQ.HTTP.post(
                                    "/bin/replicate.json",
                                    null,
                                    { "_charset_":"utf-8", "path":toActivate, "cmd":"Activate" }
                                );
                                if (!CQ.HTTP.isOk(response)) {
                                    CQ.Notification.notifyFromResponse(response);
                                }
                            }
                            if (CQ.HTTP.isOk(response)) {
                                CQ.Notification.notify(CQ.I18n.getMessage("Activate Blog Entry"),
                                        CQ.I18n.getMessage("Blog entry successfully activated"));
                            }
                        }
                    },
                    CQ.wcm.Sidekick.LOCK,
                    CQ.wcm.Sidekick.REFERENCES
                ],
                deleteText: CQ.I18n.getMessage("Delete Blog Entry"),
                lockText: CQ.I18n.getMessage("Lock Blog Entry"),
                <%
            }
            %>
            propsDialog: "<%= dlgPath == null ? "" : xssAPI.encodeForJSString(dlgPath) %>",
            locked: <%= currentPage.isLocked() %>
        });
    </script><%
}
%>
