package kz.eduquest.storage;

import io.minio.*;
import io.minio.messages.Item;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class StorageService {

    private final MinioClient minioClient;
    private final MinioProperties props;

    @EventListener(ApplicationReadyEvent.class)
    public void initBucket() {
        try {
            boolean exists = minioClient.bucketExists(
                    BucketExistsArgs.builder().bucket(props.getBucket()).build());
            if (!exists) {
                minioClient.makeBucket(
                        MakeBucketArgs.builder().bucket(props.getBucket()).build());
                log.info("MinIO bucket '{}' created", props.getBucket());
            }
            String policy = """
                    {
                      "Version": "2012-10-17",
                      "Statement": [{
                        "Effect": "Allow",
                        "Principal": {"AWS": ["*"]},
                        "Action": ["s3:GetObject"],
                        "Resource": ["arn:aws:s3:::%s/*"]
                      }]
                    }""".formatted(props.getBucket());
            minioClient.setBucketPolicy(
                    SetBucketPolicyArgs.builder()
                            .bucket(props.getBucket())
                            .config(policy)
                            .build());
            log.info("MinIO bucket '{}' policy set to public read", props.getBucket());
        } catch (Exception e) {
            log.error("MinIO bucket init failed: {}", e.getMessage());
        }
    }

    public String upload(MultipartFile file, String folder) {
        try {
            String ext = getExtension(file.getOriginalFilename());
            String objectName = folder + "/" + UUID.randomUUID() + ext;
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(props.getBucket())
                            .object(objectName)
                            .stream(file.getInputStream(), file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build());
            return props.getPublicUrl() + "/" + props.getBucket() + "/" + objectName;
        } catch (Exception e) {
            throw new RuntimeException("File upload failed: " + e.getMessage(), e);
        }
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "";
        return filename.substring(filename.lastIndexOf("."));
    }
}
