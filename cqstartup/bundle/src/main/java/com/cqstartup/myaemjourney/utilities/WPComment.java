package com.cqstartup.myaemjourney.utilities;

/**
 * Created by kari.thrastarson on 23-09-2016.
 */
public class WPComment {
    private String author;
    private String comment;
    private String date;

    /*
     * CONSTRUCTORS
     */

    public WPComment() {
        author = "";
        comment = "";
        date = "";
    }

    public WPComment(String a, String c, String d) {
        author = a;
        comment = c;
        date = d;
    }

    /*
    * GETTERS AND SETTERS
    */
    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }
}
