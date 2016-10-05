package com.cqstartup.myaemjourney.utilities;


/**
 * Created by kari.thrastarson on 23-09-2016.
 */
import java.util.ArrayList;

public class WPPost {
    private String title;
    private String author;
    private String date;
    private String content;
    private ArrayList<WPComment> comments;

    /*
     * CONSTRUCTORS
     */
    public WPPost() {
        title = "";
        author = "";
        date = "";
        content = "";
        comments = new ArrayList<WPComment>();
    }
    public WPPost(String t, String a, String d, String con, ArrayList<WPComment> com) {
        title = t;
        author = a;
        date = d;
        content = con;
        comments = com;
    }

    /*
     *  ------SETTERS------
     */

    public void setTitle(String title) {
        this.title = title;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setDate(String date) {
        this.date = date;


    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setComments(ArrayList<WPComment> comments) {
        this.comments = comments;
    }

    /*
     *  ------GETTERS------
     */
    public String getTitle() {
        return title;
    }

    public String getAuthor() {
        return author;
    }

    public String getDate() {
        return date;
    }

    public String getContent() {
        return content;
    }

    public ArrayList<WPComment> getComments() {
        return comments;
    }

    public void addComment(String commentAuthor, String commentContent, String date) {
        WPComment c = new WPComment(commentAuthor, commentContent, date);
        comments.add(c);
    }

    public String printComments() {
        StringBuilder str = new StringBuilder();
        for (WPComment c : comments) {
            str.append("On " + c.getDate() + " " + c.getAuthor() + " wrote: \n");
            str.append(c.getComment() + "\n");
        }
        return str.toString();
    }
}
