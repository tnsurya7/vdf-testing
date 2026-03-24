package com.sidbi.vdf.web;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/public")
@Tag(name = "Public", description = "Public/aggregated data (optional)")
public class PublicDataController {

    @GetMapping("/data")
    @Operation(summary = "Public aggregated data (read-only)")
    public ResponseEntity<PublicDataDto> data() {
        return ResponseEntity.ok(new PublicDataDto(
            Map.of("applications", 0, "registrations", 0),
            "Aggregated counts; implement from Application/Registration repos if needed."
        ));
    }

    @Data
    public static class PublicDataDto {
        private final Map<String, Integer> counts;
        private final String note;
    }
}
