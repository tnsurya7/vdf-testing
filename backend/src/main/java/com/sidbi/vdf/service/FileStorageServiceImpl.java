package com.sidbi.vdf.service;

import com.sidbi.vdf.domain.ApplicationFile;
import com.sidbi.vdf.repository.ApplicationFileRepository;
import com.sidbi.vdf.repository.ApplicationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class FileStorageServiceImpl implements FileStorageService {

    private final ApplicationFileRepository fileRepository;
    private final ApplicationRepository applicationRepository;

    @Value("${vdf.files.storage-path:./data/vdf-uploads}")
    private String storagePath;

    private Path root() {
        Path path = Paths.get(storagePath).toAbsolutePath().normalize();
        try {
            Files.createDirectories(path);
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory: " + path, e);
        }
        return path;
    }

    @Override
    @Transactional
    public ApplicationFile save(UUID applicationId, String scope, String label, MultipartFile file, String uploadedBy) {
        applicationRepository.findById(applicationId)
            .orElseThrow(() -> new IllegalArgumentException("Application not found: " + applicationId));

        String originalName = file.getOriginalFilename();
        if (originalName == null || originalName.isBlank()) {
            originalName = "file";
        }
        String ext = "";
        int lastDot = originalName.lastIndexOf('.');
        if (lastDot > 0) {
            ext = originalName.substring(lastDot);
        }
        String storedName = UUID.randomUUID() + ext;

        Path root = root();
        Path target = root.resolve(storedName);
        try {
            Files.copy(file.getInputStream(), target);
        } catch (IOException e) {
            log.error("Failed to store file {}", storedName, e);
            throw new RuntimeException("Could not store file: " + e.getMessage());
        }

        ApplicationFile entity = ApplicationFile.builder()
            .applicationId(applicationId)
            .scope(scope != null ? scope : "general")
            .label(label)
            .originalName(originalName)
            .storedName(storedName)
            .contentType(file.getContentType())
            .sizeBytes(file.getSize())
            .uploadedAt(Instant.now())
            .uploadedBy(uploadedBy)
            .build();
        return fileRepository.save(entity);
    }

    @Override
    public List<ApplicationFile> listByApplication(UUID applicationId, String scope) {
        if (scope == null || scope.isBlank()) {
            return fileRepository.findByApplicationIdOrderByUploadedAtDesc(applicationId);
        }
        return fileRepository.findByApplicationIdAndScopeOrderByUploadedAtDesc(applicationId, scope);
    }

    @Override
    public Resource load(UUID fileId) {
        ApplicationFile meta = fileRepository.findById(fileId)
            .orElseThrow(() -> new IllegalArgumentException("File not found: " + fileId));
        Path root = root();
        Path file = root.resolve(meta.getStoredName());
        try {
            Resource resource = new UrlResource(file.toUri());
            if (resource.exists() && resource.isReadable()) {
                return resource;
            }
            throw new RuntimeException("File not readable: " + meta.getStoredName());
        } catch (MalformedURLException e) {
            throw new RuntimeException("Invalid file path: " + file, e);
        }
    }

    @Override
    @Transactional
    public void delete(UUID fileId) {
        ApplicationFile meta = fileRepository.findById(fileId)
            .orElseThrow(() -> new IllegalArgumentException("File not found: " + fileId));
        Path root = root();
        Path file = root.resolve(meta.getStoredName());
        try {
            Files.deleteIfExists(file);
        } catch (IOException e) {
            log.warn("Could not delete file on disk: {}", meta.getStoredName(), e);
        }
        fileRepository.delete(meta);
    }

    @Override
    public ApplicationFile getById(UUID fileId) {
        return fileRepository.findById(fileId)
            .orElseThrow(() -> new IllegalArgumentException("File not found: " + fileId));
    }
}
