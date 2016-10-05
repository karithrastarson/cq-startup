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

  Blog: Entry form component.

  ==============================================================================

--%><%
%><%@ page session="false" import="java.security.AccessControlException,
                   org.apache.sling.api.SlingHttpServletRequest,
                   com.day.cq.i18n.I18n,
                   com.day.cq.security.Authorizable,
                   com.day.text.Text" %><%
%><%@include file="/libs/foundation/global.jsp" %><%

    // force login if user has no create permission on blog page
    try {
        Session session = slingRequest.getResourceResolver().adaptTo(Session.class);
        session.checkPermission(currentPage.getPath() + "/_check" +
                System.currentTimeMillis(), "add_node");

        String id = Text.createValidLabel(resource.getPath());

        Authorizable auth = ((SlingHttpServletRequest)request).getResourceResolver().
                adaptTo(Authorizable.class);
        String author = auth == null ? null : auth.getName();
        if (author == null) {
            // workaround if user manager service is not ready yet.
            author = session.getUserID();
        }

        // draw entry form
        %><cq:includeClientLib categories="cq.social.blog"/>
        <div id="CQ"><!-- todo: avoid id=CQ -->
            <form
                class="entry-form"
                action="<%= xssAPI.getValidHref(currentPage.getPath()) %>.social.createblogentry.html"
                method="POST"
                id="<%= id %>_form">

                <div id="<%= id %>_fields_wrap">
                </div>

            </form>
        </div>

        <script type="text/javascript">
            CQ.Util.build({
                "xtype":"panel",
                "border":false,
                "cls":"entry-fields-wrap",
                "layout":"form",
                "defaults": {
                    "hideLabel":true
                },
                "items":[{
                    "xtype":"textfield",
                    "defaultValue":"Entry title",
                    "cls":"title",
                    "name":"title"
                },{
                    "xtype":"richtext",
                    "id":"<%= id %>_text",
                    "name":"text",
                    "enableSourceEdit":true,
                    "width":"100%"
                },{
                    "xtype":"label",
                    "cls":"entry-field-label",
                    "text":"Categories"
                },{
                    "xtype":"tags",
                    "id":"<%= id %>_tags",
                    "name":"tags"
                },{
                    "xtype":"label",
                    "cls":"entry-field-label",
                    "text":"Display in"
                },{
                    "xtype":"panel",
                    "cls":"entry-button-group",
                    "border":false,
                    "buttonAlign":"left",
                    "buttons":[{
                            "xtype":"button",
                            "text":"Timeline",
                            "pressed":true,
                            "enableToggle":true,
                            "toggleGroup":"displayIn",
                            "handler":function() {
                                CQ.Ext.getCmp('<%= id %>_displayIn').setValue("timeline");
                            }
                        },{
                            "xtype":"button",
                            "text":"Sidebar",
                            "enableToggle":true,
                            "toggleGroup":"displayIn",
                            "handler":function() {
                                CQ.Ext.getCmp('<%= id %>_displayIn').setValue("sidebar");
                            }
                        }
                    ]
                },{
                    "xtype":"hidden",
                    "name":"displayIn",
                    "id":"<%= id %>_displayIn",
                    "value":"timeline"
                },{
                    "xtype":"hidden",
                    "name":"_charset_",
                    "value":"utf-8"
                },{
                    "xtype":"button",
                    "text":"Submit Entry",
                    "handler": function() {
                        CQ.social.blog.Util.validateEntryForm("<%= id %>");
                    }
                }],
                "renderTo":"<%= id %>_fields_wrap"
            });


        </script><%

    } catch (AccessControlException ace) {
        // draw login form
        String user = "rep:userId";
        String pass = "rep:password";
        String signInPath = "../../" + user; // workaround npe in signin
        %><cq:includeClientLib js="cq.security"/>
          <h3><%= I18n.get(slingRequest.getResourceBundle(currentPage.getLanguage(true)), "Please sign in first") %></h3><p/>
        <form
            action="<%= request.getRequestURI() %>"
            method="post"
            onsubmit="return doLogin();">
            <cq:include path="<%= signInPath %>" resourceType="foundation/components/account/signin"/>
            <input type="submit" class="signin-submit"/>
        </form>

        <script type="text/javascript">
            function doLogin() {
                try {
                    var user = document.getElementsByName('<%= user %>')[0].value;
                    var pass = document.getElementsByName('<%= pass %>')[0].value;
                    if (!user) {
                        return false;
                    }
                    CQ.User.login(user, pass);
                    document.location.reload();
                } catch (e) {
                    alert(e);
                }
                return false;
            }
        </script><%
    }
%>
