package com.sidbi.vdf.web;

import com.sidbi.vdf.domain.Application;
import com.sidbi.vdf.domain.ApplicationFile;
import com.sidbi.vdf.service.ApplicationService;
import com.sidbi.vdf.service.FileStorageService;
import com.sidbi.vdf.web.dto.ApplicationFileDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collection;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Tag(name = "Application files", description = "Upload, list, and download application attachments")
public class ApplicationFileController {

    private final FileStorageService fileStorageService;
    private final ApplicationService applicationService;

    private static boolean canAccessApplication(Application app, String principal) {
        if (principal == null) return false;
        if (app.getApplicantEmail().equals(principal)) return true;
        Collection<? extends GrantedAuthority> authorities = SecurityContextHolder.getContext().getAuthentication().getAuthorities();
        return authorities.stream()
            .anyMatch(a -> "ROLE_SIDBI".equals(a.getAuthority()) || "ROLE_ADMIN".equals(a.getAuthority()));
    }

    private static String getPrincipalEmail() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) return null;
        Object principal = auth.getPrincipal();
        return principal instanceof String ? (String) principal : null;
    }

    private static ApplicationFileDto toDto(ApplicationFile f) {
        return ApplicationFileDto.builder()
            .id(f.getId())
            .applicationId(f.getApplicationId())
            .scope(f.getScope())
            .label(f.getLabel())
            .originalName(f.getOriginalName())
            .contentType(f.getContentType())
            .sizeBytes(f.getSizeBytes())
            .uploadedAt(f.getUploadedAt())
            .uploadedBy(f.getUploadedBy())
            .build();
    }

    @PostMapping("/applications/{applicationId}/files")
    @Operation(summary = "Upload a file for an application")
    public ResponseEntity<ApplicationFileDto> upload(
        @PathVariable UUID applicationId,
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "scope", defaultValue = "general") String scope,
        @RequestParam(value = "label", required = false) String label
    ) {
        Application app = applicationService.getById(applicationId);
        String user = getPrincipalEmail();
        if (!canAccessApplication(app, user)) {
            return ResponseEntity.status(403).build();
        }
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        ApplicationFile saved = fileStorageService.save(applicationId, scope, label, file, user);
        if ("icvd".equalsIgnoreCase(scope) && "note".equalsIgnoreCase(label != null ? label : "")) {
            applicationService.updateIcvdNote(applicationId, java.util.Map.of(
                "id", saved.getId().toString(),
                "originalName", saved.getOriginalName() != null ? saved.getOriginalName() : "icvd-note"
            ));
        }
        if ("ccic".equalsIgnoreCase(scope) && "note".equalsIgnoreCase(label != null ? label : "")) {
            applicationService.updateCcicNote(applicationId, java.util.Map.of(
                "id", saved.getId().toString(),
                "originalName", saved.getOriginalName() != null ? saved.getOriginalName() : "ccic-memo"
            ));
        }
        return ResponseEntity.ok(toDto(saved));
    }

    @GetMapping("/applications/{applicationId}/files")
    @Operation(summary = "List files for an application")
    public ResponseEntity<List<ApplicationFileDto>> list(
        @PathVariable UUID applicationId,
        @RequestParam(value = "scope", required = false) String scope
    ) {
        Application app = applicationService.getById(applicationId);
        String user = getPrincipalEmail();
        if (!canAccessApplication(app, user)) {
            return ResponseEntity.status(403).build();
        }
        List<ApplicationFile> files = fileStorageService.listByApplication(applicationId, scope);
        return ResponseEntity.ok(files.stream().map(ApplicationFileController::toDto).collect(Collectors.toList()));
    }

    @GetMapping("/files/{fileId}/download")
    @Operation(summary = "Download a file by ID")
    public ResponseEntity<Resource> download(@PathVariable UUID fileId) {
        ApplicationFile meta = fileStorageService.getById(fileId);
        Application app = applicationService.getById(meta.getApplicationId());
        String user = getPrincipalEmail();
        if (!canAccessApplication(app, user)) {
            return ResponseEntity.status(403).build();
        }
        Resource resource = fileStorageService.load(fileId);
        String contentType = meta.getContentType() != null ? meta.getContentType() : "application/octet-stream";
        return ResponseEntity.ok()
            .contentType(MediaType.parseMediaType(contentType))
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + sanitizeFilename(meta.getOriginalName()) + "\"")
            .body(resource);
    }

    @DeleteMapping("/files/{fileId}")
    @Operation(summary = "Delete a file")
    public ResponseEntity<Void> delete(@PathVariable UUID fileId) {
        ApplicationFile meta = fileStorageService.getById(fileId);
        Application app = applicationService.getById(meta.getApplicationId());
        String user = getPrincipalEmail();
        if (!canAccessApplication(app, user)) {
            return ResponseEntity.status(403).build();
        }
        fileStorageService.delete(fileId);
        return ResponseEntity.noContent().build();
    }

    private static String sanitizeFilename(String name) {
        if (name == null) return "download";
        return name.replace("\"", "%22");
    }
}
