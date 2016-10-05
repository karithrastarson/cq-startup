package com.cqstartup.myaemjourney.servlets;

import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.resource.LoginException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jcr.Node;
import javax.jcr.Session;
import javax.servlet.ServletException;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.PageManager;
import com.day.cq.workflow.WorkflowService;
import com.cqstartup.myaemjourney.utilities.WPArchive;
import com.cqstartup.myaemjourney.utilities.WPComment;
import com.cqstartup.myaemjourney.utilities.WPPost;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.felix.scr.annotations.sling.SlingServlet;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ResourceResolverFactory;
import org.apache.sling.api.servlets.SlingAllMethodsServlet;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jcr.Node;
import javax.jcr.Session;
import javax.servlet.ServletException;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

/**
 * Created by kari.thrastarson on 28-09-2016.
 */
@SlingServlet(
        paths="/bin/migrate",
        methods = "GET",
        metatype=true
)
@Service
public class MigrateFeed extends SlingAllMethodsServlet {

    private static final long serialVersionUID = 1L;

    protected Logger log = LoggerFactory.getLogger(this.getClass());

    private Session session;

    private WPArchive wpArchive;

    @Reference
    private ResourceResolverFactory resolverFactory;
    private ResourceResolver resourceResolver;

    @Override
    protected void doGet(SlingHttpServletRequest req, SlingHttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/plain; charset=utf-8");
        resp.setCharacterEncoding("UTF-8");
        int a = 0;
        log.info("STATUS: " + a++);

        String externalPath = "";//req.getParameter("external_path");
        String internalPath = "";// req.getParameter("internal_path");
        if (internalPath.isEmpty()) {
            Page migratedBlog = null;
            try{
                this.resourceResolver = this.resolverFactory.getAdministrativeResourceResolver(null);
                PageManager pageManager = this.resourceResolver.adaptTo(PageManager.class);
                 migratedBlog = pageManager.create("/content/", "migratedBlog", "/apps/social/blog/templates/page", "Migrated Blog");

                internalPath = migratedBlog.getPath();
            } catch (Exception e){e.printStackTrace();}



    }
        if (externalPath.isEmpty()) {
            //externalPath = "http://fivethirtyeight.com/feed/";
              externalPath = "http://blogs.novonordisk.com/graduates/feed";
            //externalPath = "C:\\Users\\kari.prastarson\\Desktop\\testfile.xml";
        }

        resp.getWriter().write("Internal Path:" + internalPath +"\n");
        resp.getWriter().write("External Path:" + externalPath +"\n");

        log.info("Internal Path: " + internalPath);
        log.info("External Path: " + externalPath);
        log.info("STATUS: " + a++);

        wpArchive = new WPArchive(externalPath);

        try {

            ArrayList<WPPost> archive = wpArchive.getArchive();

            for(WPPost p : archive) {

                createPage(p, internalPath);
            }
            resp.getWriter().write("Success!" +"\n");
            resp.getWriter().write("Number of posts created:"+archive.size() +"\n");
            resp.getWriter().write("Number of comments created:"+wpArchive.getCommentCount() +"\n");

        } catch(Exception e) {
            resp.getWriter().write("Success...NOT!" +"\n");
            resp.getWriter().write(e.getMessage());
        }
    }

    protected void createPage(WPPost post, String path) throws Exception {

        String pageName = post.getTitle();
        String pageTitle = post.getTitle();
        String template = "/apps/social/blog/templates/page";
        String renderer = "social/blog/components/page";

        this.resourceResolver = this.resolverFactory.getAdministrativeResourceResolver(null);
        Page blogEntryPage = null;
        Session session = this.resourceResolver.adaptTo(Session.class);

        String year = post.getDate().substring(12,16);
        String month = post.getDate().substring(8,12);
        Date date = new SimpleDateFormat("MMM", Locale.ENGLISH).parse(month);
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        month = Integer.toString(cal.get(Calendar.MONTH) + 1);
        if(cal.get(Calendar.MONTH) + 1 <10){month = "0" + month;}

        log.info("TEST NEW MONTH: " + month);

        PageManager pageManager = this.resourceResolver.adaptTo(PageManager.class);
        Page archivePage = pageManager.getPage(path+year+"/"+month);

        if(archivePage == null){
            log.info("Creating a subpage");
            archivePage = createSubPages(path, year, month);
        }

        try {
            if (session != null) {
                log.info("CREATE BLOG ENTRY");

                //See if it already exists
                blogEntryPage = pageManager.getPage(archivePage.getPath()+"/"+ pageTitle.replaceAll("\\s+",""));

                if (blogEntryPage == null) {
                    //Create Page if doesn't exist
                    blogEntryPage = pageManager.create(archivePage.getPath(), pageTitle.replaceAll("\\s+", ""), template, pageTitle);
                }

                Node pageNode = blogEntryPage.adaptTo(Node.class);

                Node jcrNode = null;
                if (blogEntryPage.hasContent()){
                    jcrNode = blogEntryPage.getContentResource().adaptTo(Node.class);
                }

                else {
                    jcrNode = pageNode.addNode("jcr:content" , "cq:PageContent");
                }

                jcrNode.setProperty("sling:resourceType",renderer);
                jcrNode.setProperty("_charset_", "UTF-8");
                log.info("The Author is registered as: " + post.getAuthor());
                jcrNode.setProperty("author", post.getAuthor());
                jcrNode.setProperty("cq:distribute", true);
                jcrNode.setProperty("cq:template", template);
                jcrNode.setProperty("hideInNav", true);

                //Convert to date format
                SimpleDateFormat sdf = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z",Locale.ENGLISH);
                Date parsedDate = sdf.parse(post.getDate());

                SimpleDateFormat postDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");

                Calendar pd = Calendar.getInstance();
                pd.setTime(parsedDate);
                jcrNode.setProperty("published",pd);// postDate.format(parsedDate));
                log.info("HERE IS THE NEW DATE FORMAT: " + postDate.format(parsedDate));


                Node parNode = jcrNode.addNode("par");
                Node altNode = jcrNode.addNode("alt");

                parNode.setProperty("sling:resourceType","foundation/components/parsys");

                Node textNode = parNode.addNode("entry");

                textNode.setProperty("sling:resourceType", "social/blog/components/entrytext");
                textNode.setProperty("textIsRich", "true");
                textNode.setProperty("text", post.getContent());

                altNode.setProperty("sling:resourceType", "foundation/components/parsys");
                Node comments = altNode.addNode("comments");
                comments.setProperty("sling:resourceType","social/commons/components/comments");

                Node trackback = altNode.addNode("trackback");
                trackback.setProperty("sling:resourceType","social/blog/components/trackback");


                //CREATE COMMENTS
                createComments(blogEntryPage.getPath(),post);
                log.info("ATTEMPT CREATING COMMENTS FOR POST: " + blogEntryPage.getPath());

                session.save();
                session.refresh(true);
            }
        } catch(Exception e) {

            log.info("Try caught: " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected Page createSubPages(String path, String year, String month)  {
        boolean success = false;
        Page monthPage = null;
        log.info("CREATING SUB PAGE: " + path + "/" + month);
        try {
            this.resourceResolver = this.resolverFactory.getAdministrativeResourceResolver(null);
            Session session = this.resourceResolver.adaptTo(Session.class);

            if(session != null) {
                log.info("Session not null");
                PageManager pageManager = this.resourceResolver.adaptTo(PageManager.class);
                Page rootPage = pageManager.getPage(path);

                Page yearPage = pageManager.getPage(path + year);
                if(yearPage == null) {

                    log.info("yearPage is null");
                    log.info("Creating yearPage at path:" + path+year);
                    yearPage = pageManager.create(path, year, "/apps/social/blog/templates/page", year);

                    Node yearNode = yearPage.adaptTo(Node.class);
                    Node jcrNode = yearPage.getContentResource().adaptTo(Node.class);

                    jcrNode.setProperty("sling:resourceType","social/blog/components/page");
                    jcrNode.setProperty("jcr:title", year);
                    jcrNode.setProperty("blogarchive", year);

                }

                else {
                    log.info("yearpage is not null: " + yearPage.getTitle());
                }
                monthPage = pageManager.getPage(path + year + "/" + month);

                if(monthPage == null) {
                    log.info("monthPage is null");
                    monthPage = pageManager.create(path + year ,month, "social/blog/components/page", month);
                    Node monthNode = monthPage.adaptTo(Node.class);
                    Node jcrNode = monthPage.getContentResource().adaptTo(Node.class);

                    jcrNode.setProperty("sling:resourceType","social/blog/components/page");
                    jcrNode.setProperty("jcr:title", month);
                    jcrNode.setProperty("blogarchive", year+"/"+month);

                }
                else{
                    log.info("monthpage is not null" + monthPage.getTitle());
                }
            }
            session.save();
            success = true;
        } catch (Exception e) {
            log.info("Exception caught in CREATESUBPAGES: " + e.getMessage());
            success = false;
        }

        log.info("RETURNING MONTH PAGE: " + monthPage.getPath());
        return monthPage;
    }

    protected void createComments(String blogPath, WPPost post) {
        String path = "/content/usergenerated/content/novo/graduate_blog/";

        //First check if post has any comments:
        if(!post.getComments().isEmpty()) {

            try {
                PageManager pageManager = this.resourceResolver.adaptTo(PageManager.class);

                ArrayList<WPComment> comments = post.getComments();

                String year = post.getDate().substring(12, 16);
                String month = post.getDate().substring(8, 12);
                log.info("CREATE COMMENTS, WITH MONTH: " + month + " and YEAR: " + year);
                Date date = new SimpleDateFormat("MMM", Locale.ENGLISH).parse(month);
                Calendar cal = Calendar.getInstance();
                cal.setTime(date);
                month = Integer.toString(cal.get(Calendar.MONTH) + 1);
                if(cal.get(Calendar.MONTH) + 1 <10){month = "0" + month;}

                Page commentPage = createSubPages(path, year, month);
                log.info("The Comment Page is ready: " + commentPage.getPath());
                Page blogEntryPage;
                blogEntryPage =  pageManager.getPage(commentPage.getPath()+ "/"+ post.getTitle().replaceAll("\\s+",""));

                if(blogEntryPage == null) {
                    //create if doesn't exist
                    blogEntryPage = pageManager.create(commentPage.getPath(),post.getTitle().replaceAll("\\s+","") , "/apps/social/blog/templates/page", post.getTitle());
                }

                log.info("Fetching JCR node");
                Node jcrNode = blogEntryPage.getContentResource().adaptTo(Node.class);
                log.info("JCR node established");
                Node cmnts = jcrNode.addNode("comments");
                log.info("comments node created");
                cmnts.setProperty("commentsNode", blogPath+"/jcr:content/alt/comments");
                cmnts.setProperty("cq:lastReplicationBy","admin");
                cmnts.setProperty("cq:lastReplicationAction", "Activate");

                Node bucket = cmnts.addNode("1Bucket", "sling:Folder");
                int a=0;
                for(WPComment c : comments) {
                    Node n = bucket.addNode("comment"+a++, "cq:Comment");
                    n.setProperty("activityCreated",true);

                    //Convert to date format
                    SimpleDateFormat sdf = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z",Locale.ENGLISH);
                    Date parsedDate = sdf.parse(post.getDate());

                    SimpleDateFormat postDate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");

                    Calendar pd = Calendar.getInstance();
                    pd.setTime(parsedDate);
                    n.setProperty("added",pd);

                    n.setProperty("approved",true);
                    n.setProperty("authorizableId",c.getAuthor());
                    n.setProperty("cq:lastReplicated","");
                    n.setProperty("cq:lastReplicatedBy","admin");
                    n.setProperty("cq:lastReplicationAction","Active");
                    n.setProperty("email","");
                    n.setProperty("ip","");
                    n.setProperty("jcr:description",c.getComment());
                    n.setProperty("jcr:mixinTypes","cq:ReplicationStatus");
                    n.setProperty("negative",0);
                    n.setProperty("positive",0);
                    n.setProperty("referer",blogPath+".html");
                    n.setProperty("sentiment","");
                    n.setProperty("sling:resourceType","social/commons/components/comments/comment");
                    n.setProperty("url","");
                    n.setProperty("userAgent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36");
                    n.setProperty("userIdentifier",c.getAuthor());
                }

            } catch(Exception e) {
                log.info("Exception caught when generating comments: " + e.getMessage() +"\n");
            }
        }
    }
}