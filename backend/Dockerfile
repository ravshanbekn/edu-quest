# Stage 1: Build
FROM gradle:9.3-jdk17-alpine AS builder
WORKDIR /app
COPY . .
RUN gradle bootJar --no-daemon -x test

# Stage 2: Run
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]
