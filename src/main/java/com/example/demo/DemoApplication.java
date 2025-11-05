package com.example.demo;

import com.example.demo.model.BlogPost;
import com.example.demo.service.BlogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
public class DemoApplication {

  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }

  @Controller
  public static class BlogController {

    @Autowired
    private BlogService blogService;

    @GetMapping("/")
    public String home(Model model) {
      model.addAttribute("posts", blogService.getAllPosts());
      model.addAttribute("tags", blogService.getAllTags());
      model.addAttribute("postCount", blogService.getPostCount());
      return "index";
    }

    @GetMapping("/post/{id}")
    public String viewPost(@PathVariable Long id, Model model) {
      BlogPost post = blogService.getPostById(id);
      if (post == null) {
        return "redirect:/";
      }
      model.addAttribute("post", post);
      model.addAttribute("tags", blogService.getAllTags());
      return "post";
    }

    @GetMapping("/tag/{tag}")
    public String viewPostsByTag(@PathVariable String tag, Model model) {
      model.addAttribute("posts", blogService.getPostsByTag(tag));
      model.addAttribute("tagName", tag);
      model.addAttribute("allTags", blogService.getAllTags());
      return "tag";
    }

    @GetMapping("/about")
    public String about(Model model) {
      model.addAttribute("tags", blogService.getAllTags());
      return "about";
    }
  }

  @RestController
  public static class ApiController {

    @Autowired
    private BlogService blogService;

    @GetMapping("/api/info")
    public Map<String, Object> info() {
      Map<String, Object> info = new HashMap<>();
      info.put("app", "java-azure-demo-blog");
      info.put("version", "2.0.0");
      info.put("platform", "Azure Container Apps");
      info.put("java_version", System.getProperty("java.version"));
      info.put("timestamp", System.currentTimeMillis());
      info.put("blog_posts", blogService.getPostCount());
      info.put("available_tags", blogService.getAllTags());
      return info;
    }

    @GetMapping("/api/posts")
    public Map<String, Object> getAllPosts() {
      Map<String, Object> response = new HashMap<>();
      response.put("posts", blogService.getAllPosts());
      response.put("total", blogService.getPostCount());
      return response;
    }
  }
}
