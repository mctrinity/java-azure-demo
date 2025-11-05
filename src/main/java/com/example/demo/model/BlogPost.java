package com.example.demo.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class BlogPost {
    private Long id;
    private String title;
    private String content;
    private String author;
    private LocalDateTime publishedDate;
    private String tags;
    private String excerpt;

    public BlogPost() {}

    public BlogPost(Long id, String title, String content, String author, String tags) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.author = author;
        this.publishedDate = LocalDateTime.now();
        this.tags = tags;
        this.excerpt = content.length() > 150 ? content.substring(0, 150) + "..." : content;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { 
        this.content = content;
        this.excerpt = content.length() > 150 ? content.substring(0, 150) + "..." : content;
    }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public LocalDateTime getPublishedDate() { return publishedDate; }
    public void setPublishedDate(LocalDateTime publishedDate) { this.publishedDate = publishedDate; }

    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }

    public String getExcerpt() { return excerpt; }
    public void setExcerpt(String excerpt) { this.excerpt = excerpt; }

    public String getFormattedDate() {
        return publishedDate.format(DateTimeFormatter.ofPattern("MMMM dd, yyyy 'at' HH:mm"));
    }

    public String getReadingTime() {
        int words = content.split("\\s+").length;
        int readingTime = Math.max(1, words / 200); // Average reading speed: 200 words per minute
        return readingTime + " min read";
    }
}