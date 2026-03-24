package com.sidbi.vdf.service;

import com.sidbi.vdf.domain.ApplicationFile;
import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface FileStorageService {

    /**
     * Store an uploaded file for an application. Saves to disk and persists metadata.
     *
     * @param applicationId application this file belongs to
     * @param scope         e.g. prelim, detailed, icvd, ccic
     * @param label         optional slot/label (e.g. docPitchDeck)
     * @param file          the uploaded file
     * @param uploadedBy    email of the user uploading
     * @return saved ApplicationFile metadata
     */
    ApplicationFile save(UUID applicationId, String scope, String label, MultipartFile file, String uploadedBy);

    /**
     * List all files for an application, optionally filtered by scope.
     */
    List<ApplicationFile> listByApplication(UUID applicationId, String scope);

    /**
     * Load file content as a Resource for download. Caller must ensure access control.
     */
    Resource load(UUID fileId);

    /**
     * Delete a file from storage and database.
     */
    void delete(UUID fileId);

    /**
     * Get file metadata by id.
     */
    ApplicationFile getById(UUID fileId);
}
