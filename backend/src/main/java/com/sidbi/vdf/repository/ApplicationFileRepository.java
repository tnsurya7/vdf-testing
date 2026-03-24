package com.sidbi.vdf.repository;

import com.sidbi.vdf.domain.ApplicationFile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ApplicationFileRepository extends JpaRepository<ApplicationFile, UUID> {

    List<ApplicationFile> findByApplicationIdOrderByUploadedAtDesc(UUID applicationId);

    List<ApplicationFile> findByApplicationIdAndScopeOrderByUploadedAtDesc(UUID applicationId, String scope);

    Optional<ApplicationFile> findByStoredName(String storedName);
}
