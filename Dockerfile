# Use Eclipse Temurin OpenJDK 17 as base image (official and maintained)
FROM eclipse-temurin:17-jdk-alpine

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