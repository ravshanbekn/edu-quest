package kz.eduquest.storage;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class MinioConfig {

    private final MinioProperties props;

    @Bean
    public MinioClient minioClient() throws Exception {
        MinioClient client = MinioClient.builder()
                .endpoint(props.getUrl())
                .credentials(props.getAccessKey(), props.getSecretKey())
                .build();

        // Создать бакет если не существует
        if (!client.bucketExists(BucketExistsArgs.builder().bucket(props.getBucket()).build())) {
            client.makeBucket(MakeBucketArgs.builder().bucket(props.getBucket()).build());
            log.info("Created MinIO bucket: {}", props.getBucket());
        }

        return client;
    }
}
