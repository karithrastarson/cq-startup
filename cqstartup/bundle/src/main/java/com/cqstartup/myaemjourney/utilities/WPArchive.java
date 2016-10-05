package com.cqstartup.myaemjourney.utilities;


import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.*;
import java.net.URL;
import java.util.ArrayList;

/*
 * Created by kari.thrastarson on 22-09-2016.
 */

public class WPArchive {

    //Full path of XML export file from WordPress
    private String xmlFile;
    private ArrayList<WPPost> archive;

    public  WPArchive(String path) {
        xmlFile = path;
        init();
    }

    public void init() {

        try {
            //Check if path is url or file
            URL url = null;
            boolean isUrl = false;
            try {
                url = new URL(xmlFile);
                isUrl = true;


            } catch(Exception e) {

            }
            FileInputStream file;
            if (isUrl) {

             //   PrintWriter writer = //new PrintWriter("url.xml", "UTF-8");
               // new PrintWriter(new OutputStreamWriter(
                  //      url.getOutputStream(), StandardCharsets.UTF_8), true);
                        Writer writer = new BufferedWriter(new OutputStreamWriter(
                        new FileOutputStream("url.xml"), "UTF-8"));


                BufferedReader in = new BufferedReader(
                        new InputStreamReader(url.openStream()));

                String inputLine;
                while ((inputLine = in.readLine()) != null)
                    writer.write(inputLine);
                in.close();
                file = new FileInputStream(new File("url.xml"));//new File("url.xml");

                writer.close();
            }
            else {
                file = new FileInputStream(new File(xmlFile));//new File(xmlFile);
            }

            DocumentBuilder dBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            Document doc = dBuilder.parse(file, "UTF-8");




            archive = new ArrayList<WPPost>();

            if (doc.hasChildNodes()) {
                NodeList nodeList = doc.getChildNodes();

                //Let's find all nodes that are the actual blogs:
                NodeList blogList = doc.getElementsByTagName("item");

                extractInfo(blogList, !isUrl);
            }
        }
        catch (Exception e) {
           // System.out.println("Cause: " + e.getCause() + "\nMessage: " + e.getMessage());
        }
    }

    private void extractInfo(NodeList nodeList, boolean isFile) throws ParserConfigurationException {

        boolean isPost = false;
        for (int i = 0; i < nodeList.getLength(); i++) {

            Node tempNode = nodeList.item(i);

            //Is this node a post?
            if (isFile) {
                Element postType = (Element) tempNode;

                NodeList pt = postType.getElementsByTagName("wp:post_type");

                isPost = (pt.item(0).getTextContent().equals("post"));
            }
            else{
                isPost = true;
            }


            if (isPost) {

                WPPost currentPost = new WPPost();

                Element titleElement = (Element) tempNode;
                NodeList te = titleElement.getElementsByTagName("title");

                Element authorElement = (Element) tempNode;
                NodeList ae = authorElement.getElementsByTagName("dc:creator");

                Element dateElement = (Element) tempNode;
                NodeList de = dateElement.getElementsByTagName("pubDate");

                Element contentElement = (Element) tempNode;
                NodeList ce = contentElement.getElementsByTagName("content:encoded");

                Element comments = (Element) tempNode;
                NodeList commentList = contentElement.getElementsByTagName("wp:comment");

                //Process Comments
                currentPost = processComments(currentPost, commentList);

                currentPost.setAuthor(ae.item(0).getTextContent());
                currentPost.setTitle(te.item(0).getTextContent());
                currentPost.setContent(ce.item(0).getTextContent());
                currentPost.setDate(de.item(0).getTextContent());

                if (!(currentPost.getAuthor().isEmpty() && currentPost.getContent().isEmpty() && currentPost.getTitle().isEmpty()))
                    archive.add(currentPost);
            }
        }
    }

    private WPPost processComments(WPPost currentPost, NodeList comments) {

        for (int i = 0; i < comments.getLength(); i++) {
            Node currentComment = comments.item(i);

            Element type = (Element) currentComment;
            NodeList t = type.getElementsByTagName("wp:comment_type");


            if (!t.item(0).getTextContent().equals("pingback")) {
                Element author = (Element) currentComment;
                NodeList ae = author.getElementsByTagName("wp:comment_author");

                Element date = (Element) currentComment;
                NodeList de = author.getElementsByTagName("wp:comment_date");

                Element content = (Element) currentComment;
                NodeList ce = content.getElementsByTagName("wp:comment_content");

                currentPost.addComment(ae.item(0).getTextContent(), ce.item(0).getTextContent(), de.item(0).getTextContent());
            }
        }
        return currentPost;
    }

    private boolean isValidBlog(NodeList nodeList) {

        boolean returnValue = true;

        for (int i = 0; i < nodeList.getLength(); i++) {
            Node tempNode = nodeList.item(i);

            if (tempNode.getNodeName() == "content:encoded") {
                if (tempNode.getTextContent().isEmpty() ) {
                    returnValue = false;
                }
            }

            if (tempNode.getNodeName() == "title") {
                if (tempNode.getTextContent().isEmpty()) {
                    returnValue = false;
                }
            }

            if(nodeList.item(i).hasChildNodes()) {
                return (isValidBlog(nodeList.item(i).getChildNodes()) && returnValue);
            }
            else {
                return returnValue;
            }
        }
        return false;
    }

    public String printArchive() {
        StringBuilder str = new StringBuilder();
        System.out.println(archive.size());
        for (WPPost p : archive) {

            str.append("Title: " + p.getTitle() +"\n");
            str.append("Author: " + p.getAuthor()+"\n");
            str.append("Content: " + p.getContent()+"\n");
           str.append("Comments: " + p.printComments());
        }
        return str.toString();
    }

    public ArrayList<WPPost> getArchive() {
        return archive;
    }

    public int getCommentCount() {
        int count = 0;
        for (WPPost p : archive) {
            count+=p.getComments().size();
        }
        return count;
    }
}
