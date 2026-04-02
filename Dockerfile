# Stage 1: JAR 파일의 레이어를 추출하는 단계
FROM bellsoft/liberica-openjdk-alpine:17 AS builder
WORKDIR /builder
COPY build/libs/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# Stage 2: 실행을 위한 경량화된 JRE 단계
FROM bellsoft/liberica-openjre-alpine:17
WORKDIR /application
COPY --from=builder /builder/dependencies/ ./
COPY --from=builder /builder/spring-boot-loader/ ./
COPY --from=builder /builder/snapshot-dependencies/ ./
COPY --from=builder /builder/application/ ./

# 어플리케이션 실행 (Spring Boot 3.2+ 기본 로더)
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]