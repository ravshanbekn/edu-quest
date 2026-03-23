package kz.eduquest.storage;

import io.minio.*;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class StorageService {

    private final MinioClient minioClient;
    private final MinioProperties props;

    /**
     * Загружает файл в MinIO и возвращает объектный путь (key).
     *
     * @param folder подпапка, например "avatars"
     * @param file   загружаемый файл
     * @return objectKey вида "avatars/uuid.ext"
     */
    public String upload(String folder, MultipartFile file) {
        String extension = extractExtension(file.getOriginalFilename());
        String objectKey = folder + "/" + UUID.randomUUID() + extension;

        try (InputStream is = file.getInputStream()) {
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(props.getBucket())
                            .object(objectKey)
                            .stream(is, file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build()
            );
            log.info("Uploaded: {}/{}", props.getBucket(), objectKey);
        } catch (Exception e) {
            throw new RuntimeException("Failed to upload file to MinIO", e);
        }

        return objectKey;
    }

    /**
     * Возвращает публичный URL для скачивания объекта.
     */
    public String getUrl(String objectKey) {
        try {
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(props.getBucket())
                            .object(objectKey)
                            .expiry(60 * 60 * 24) // 24 часа
                            .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate presigned URL", e);
        }
    }

    /**
     * Удаляет объект из MinIO.
     */
    public void delete(String objectKey) {
        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(props.getBucket())
                            .object(objectKey)
                            .build()
            );
            log.info("Deleted: {}/{}", props.getBucket(), objectKey);
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete file from MinIO", e);
        }
    }

    private String extractExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "";
        return filename.substring(filename.lastIndexOf('.'));
    }
}
