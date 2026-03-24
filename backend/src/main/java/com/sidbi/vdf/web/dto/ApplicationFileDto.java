package com.sidbi.vdf.web.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Data
@Builder
public class ApplicationFileDto {

    private UUID id;
    private UUID applicationId;
    private String scope;
    private String label;
    private String originalName;
    private String contentType;
    private Long sizeBytes;
    private Instant uploadedAt;
    private String uploadedBy;
}
