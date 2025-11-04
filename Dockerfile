# Use OpenJDK 17 as base image
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Copy the pre-built JAR file from GitHub Actions
COPY target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Set environment variables
ENV JAVA_OPTS=""
ENV PORT=8080

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=$PORT -jar app.jar"]