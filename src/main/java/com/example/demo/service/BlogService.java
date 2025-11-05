package com.example.demo.service;

import com.example.demo.model.BlogPost;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class BlogService {
    private final Map<Long, BlogPost> blogPosts = new HashMap<>();
    private Long nextId = 1L;

    public BlogService() {
        // Initialize with some sample blog posts
        initializeSamplePosts();
    }

    private void initializeSamplePosts() {
        createPost("Welcome to Azure Container Apps Blog", 
                  "This blog is running on Azure Container Apps, demonstrating the power of serverless containers. " +
                  "Azure Container Apps provides a fully managed serverless container service that enables you to run " +
                  "microservices and containerized applications on a serverless platform. With built-in support for " +
                  "Kubernetes concepts like deployments, services, and ingress, it simplifies the deployment and management " +
                  "of containerized applications. The service automatically scales your applications based on HTTP traffic, " +
                  "event-driven processing, CPU or memory load, or any KEDA-supported scalers.", 
                  "Azure Team", "azure, containers, serverless");

        createPost("Java Spring Boot in the Cloud", 
                  "Spring Boot makes it easy to create stand-alone, production-grade Spring based Applications. " +
                  "When combined with Azure Container Apps, you get a powerful platform for deploying Java applications. " +
                  "This setup provides automatic scaling, built-in load balancing, and seamless CI/CD integration. " +
                  "The combination of Spring Boot's convention-over-configuration approach and Azure's managed infrastructure " +
                  "allows developers to focus on business logic rather than infrastructure management. With features like " +
                  "health checks, metrics collection, and distributed tracing, your Java applications are production-ready " +
                  "from day one.", 
                  "Java Developer", "java, spring-boot, cloud");

        createPost("Infrastructure as Code with Terraform", 
                  "Terraform enables you to safely and predictably create, change, and improve infrastructure. " +
                  "This blog's infrastructure is completely defined in code, making it reproducible and version-controlled. " +
                  "By using Terraform with Azure, we can provision resources like Container Apps, Container Registry, " +
                  "and Log Analytics Workspaces with a single command. This approach ensures consistency across environments " +
                  "and enables teams to treat infrastructure as software. The declarative nature of Terraform means you " +
                  "describe the desired end state, and Terraform figures out how to get there, making infrastructure management " +
                  "much more predictable and reliable.", 
                  "DevOps Engineer", "terraform, iac, devops");

        createPost("CI/CD with GitHub Actions", 
                  "Continuous Integration and Continuous Deployment are essential for modern software development. " +
                  "This application uses GitHub Actions to automatically build, test, and deploy code changes. " +
                  "The pipeline includes building the Java application with Maven, creating Docker images, pushing to " +
                  "Azure Container Registry, and deploying to Container Apps. This automation ensures that every code " +
                  "change goes through the same rigorous process, reducing the chance of human error and enabling faster, " +
                  "more reliable releases. The pipeline also includes security scanning, dependency checking, and " +
                  "automated testing to maintain high code quality.", 
                  "CI/CD Specialist", "github-actions, cicd, automation");

        createPost("Monitoring and Observability", 
                  "Modern applications require comprehensive monitoring and observability to ensure reliability and performance. " +
                  "This blog uses Azure Log Analytics for centralized logging, Spring Boot Actuator for health checks and metrics, " +
                  "and Container Apps built-in monitoring for infrastructure metrics. These tools provide visibility into " +
                  "application performance, error rates, and system health. With proper observability, teams can quickly " +
                  "identify and resolve issues, understand user behavior, and make data-driven decisions about application " +
                  "improvements. The combination of application metrics, infrastructure metrics, and distributed tracing " +
                  "provides a complete picture of system health.", 
                  "SRE Team", "monitoring, observability, logs");
    }

    public List<BlogPost> getAllPosts() {
        return blogPosts.values().stream()
                .sorted((a, b) -> b.getPublishedDate().compareTo(a.getPublishedDate()))
                .collect(Collectors.toList());
    }

    public BlogPost getPostById(Long id) {
        return blogPosts.get(id);
    }

    public BlogPost createPost(String title, String content, String author, String tags) {
        BlogPost post = new BlogPost(nextId++, title, content, author, tags);
        blogPosts.put(post.getId(), post);
        return post;
    }

    public List<BlogPost> getPostsByTag(String tag) {
        return blogPosts.values().stream()
                .filter(post -> post.getTags().toLowerCase().contains(tag.toLowerCase()))
                .sorted((a, b) -> b.getPublishedDate().compareTo(a.getPublishedDate()))
                .collect(Collectors.toList());
    }

    public List<String> getAllTags() {
        return blogPosts.values().stream()
                .flatMap(post -> Arrays.stream(post.getTags().split(",\\s*")))
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    public long getPostCount() {
        return blogPosts.size();
    }
}