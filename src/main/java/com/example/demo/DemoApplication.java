package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class DemoApplication {

  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }

  @GetMapping("/")
  public String home() {
    return "Hello from Java App deployed to Azure Container Apps!";
  }

  @GetMapping("/api/info")
  public Map<String, Object> info() {
    Map<String, Object> info = new HashMap<>();
    info.put("app", "java-azure-demo");
    info.put("version", "1.0.0");
    info.put("platform", "Azure Container Apps");
    info.put("java_version", System.getProperty("java.version"));
    info.put("timestamp", System.currentTimeMillis());
    return info;
  }
}
