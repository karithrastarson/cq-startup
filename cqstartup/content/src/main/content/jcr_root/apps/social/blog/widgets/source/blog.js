/*
 *
 * ADOBE CONFIDENTIAL
 * __________________
 *
 *  Copyright 2011 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 */
// ensure CQ.social.blog namespace
if (!window.CQ) {window.CQ = {};}
if (!window.CQ.social) {window.CQ.social = {};}
if (!window.CQ.social.blog) {window.CQ.social.blog = {};}

/**
 * The <code>CQ.social.blog.Util</code> class provides Utility methods for blog
 * components.
 * @class CQ.social.blog.Util
 */
CQ.social.blog.Util = function() {

    var COLLAB_ADMIN_URL = "/socoadmin.html";

    var UGC_PREFIX = "/content/usergenerated";

    var UGC_JSON_SUFFIX = ".ugc.json";

    var BLOGINFO_JSON_SUFFIX = ".social.bloginfo.json";

    var multiWinMode = false;

    var blogInfo;

    var getBlogInfo = function() {
        var path = CQ.WCM.getPagePath();
        if (blogInfo == undefined) {
            blogInfo = CQ.HTTP.eval(path + BLOGINFO_JSON_SUFFIX);
        }
        return blogInfo;
    };

    var getCommentsButton = function(info) {
        var text = CQ.I18n.getMessage("No comments");
        if (info.comments > 0) {
            if (info.comments == 1) {
                if (info.spam == 0) {
                    text = CQ.I18n.getMessage("1 Comment (No spam)");
                } else {
                    text = CQ.I18n.getMessage("1 Comment (Spam)");
                }
            } else {
                if (info.spam == 0) {
                    text = CQ.I18n.getMessage("{0} Comments (No spam)", info.comments);
                } else {
                    text = CQ.I18n.getMessage("{0} Comments ({1} Spam)", [info.comments, info.spam]);
                }
            }
        }
        var tooltip = CQ.I18n.getMessage("Manage comments");
        return new CQ.Ext.Button({
            text:text,
            tooltip:tooltip,
            hidden: !info.comments,
            handler: function(){
                CQ.social.blog.Util.openCollabAdmin();
            }
        })
    };

    var getBlogItems = function(info) {
        var text = CQ.I18n.getMessage("Blog");
        if (info.entries > 0) {
            var statsText = "";
            // entries
            if (info.entries == 1) {
                statsText = CQ.I18n.getMessage("1 Entry", null, "blog");
            } else {
                statsText = CQ.I18n.getMessage("{0} Entries", info.entries, "blog");
            }
            text += "&nbsp;&nbsp;&nbsp;" + statsText;
            /*
            // drafts
            var draftsText;
            if (info.drafts > 0) {
                if (info.drafts == 1) {
                    draftsText = CQ.I18n.getMessage("1 Draft");
                } else {
                    draftsText = CQ.I18n.getMessage("{0} Drafts", info.drafts);
                }
            } else {
                draftsText = CQ.I18n.getMessage("No drafts");
            }
            text += " (" + draftsText + ")";
            */
            /*
            // authors
            if (info.authors.length > 0) {
                var authorsText;
                if (info.authors.length == 1) {
                    authorsText = CQ.I18n.getMessage("1 Author");
                } else {
                    authorsText = CQ.I18n.getMessage("{0} Authors", info.authors.length);
                }
                text += ", " + authorsText;
            }
            */
        }
        return [
            new CQ.Ext.Toolbar.TextItem({
                text:text
            }),
            "-",
            new CQ.Ext.Button({
                text: CQ.I18n.getMessage("Add Entry", null, "blog"),
                tooltip: CQ.I18n.getMessage("Add a new entry to this blog"),
                hidden: info.entry != undefined,
                handler: function() {
                    CQ.shared.Util.load(CQ.HTTP.externalize(info.path + '.html?blog=new'));
                }
            }),
            info.comments ? "-" : "",
            getCommentsButton(info)
        ];
    };

    var getBlogEntryItems = function(info) {
        var text = CQ.I18n.getMessage("Blog Entry");
        /*
        // draft
        if (info.entry.draft) {
            text += " (" + CQ.I18n.getMessage("Draft") + ")";
        }
         */
        return [
            new CQ.Ext.Toolbar.TextItem({
                text:text
            }),
            info.comments ? "-" : "",
            getCommentsButton(info),
            "-",
            new CQ.Ext.Button({
                text: CQ.I18n.getMessage("Back to Blog"),
                tooltip: CQ.I18n.getMessage("Go back to the main page of this blog"),
                handler: function() {
                    CQ.shared.Util.load(CQ.HTTP.externalize(info.path + '.html'));
                }
            })
        ];
    };

    return {

        /**
         * Validates the form input before the entry form gets submitted
         * @param idPrefix The prefix for the IDs
         * @static
         */
        validateEntryForm: function(idPrefix) {
            try {
                var text = CQ.Ext.getCmp(idPrefix + "_text");
                text.syncValue();
                var tags = CQ.Ext.getCmp(idPrefix + "_tags");
                if (!tags.prepareSubmit()) {
                    return;
                }
                document.getElementById(idPrefix + "_form").submit();
            } catch (e) {
                alert(e.message);
            }
        },

        /**
         * Opens the administration interface using the current page path.
         * Optionally, the view can be preset.
         * @static
         */
        openCollabAdmin: function() {
            var pagePath = CQ.WCM.getPagePath();
            var url = COLLAB_ADMIN_URL + "#" + UGC_PREFIX + pagePath;
            CQ.shared.Util.open(CQ.HTTP.externalize(url));
        },

        // private
        loadBlogToolbar: function(tb) {
            var info = getBlogInfo();
            tb.add(info.entry ? getBlogEntryItems(info) : getBlogItems(info));
            tb.doLayout();
        }
    };

}();

