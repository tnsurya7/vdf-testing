package com.sidbi.vdf.web;

import com.sidbi.vdf.domain.Registration;
import com.sidbi.vdf.domain.UserAccount;
import com.sidbi.vdf.domain.enums.RegistrationStatus;
import com.sidbi.vdf.repository.UserAccountRepository;
import com.sidbi.vdf.service.RegistrationService;
import com.sidbi.vdf.web.dto.RegistrationCreateRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/registrations")
@RequiredArgsConstructor
@Tag(name = "Registrations", description = "Company registration (admin list/approve; applicant create)")
public class RegistrationController {

    private final RegistrationService registrationService;
    private final UserAccountRepository userAccountRepository;

    /** Registration DTO enriched with linked account info */
    public record RegistrationDto(
        UUID id,
        String email,
        String nameOfApplicant,
        String registeredOffice,
        String locationOfFacilities,
        String dateOfIncorporation,
        String dateOfCommencement,
        String panNo,
        String gstNo,
        String cin,
        String msmeStatus,
        String status,
        String submittedAt,
        UUID userId,
        Boolean accountEnabled
    ) {}

    private RegistrationDto toDto(Registration reg) {
        Optional<UserAccount> user = userAccountRepository.findByEmail(reg.getEmail());
        return new RegistrationDto(
            reg.getId(),
            reg.getEmail(),
            reg.getNameOfApplicant(),
            reg.getRegisteredOffice(),
            reg.getLocationOfFacilities(),
            reg.getDateOfIncorporation(),
            reg.getDateOfCommencement(),
            reg.getPanNo(),
            reg.getGstNo(),
            reg.getCin(),
            reg.getMsmeStatus() != null ? reg.getMsmeStatus().name() : null,
            reg.getStatus() != null ? reg.getStatus().name() : null,
            reg.getSubmittedAt() != null ? reg.getSubmittedAt().toString() : null,
            user.map(UserAccount::getId).orElse(null),
            user.map(UserAccount::isEnabled).orElse(null)
        );
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "List registrations (admin)")
    public ResponseEntity<List<RegistrationDto>> list() {
        return ResponseEntity.ok(registrationService.list().stream().map(this::toDto).toList());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get registration by ID (admin)")
    public ResponseEntity<RegistrationDto> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(toDto(registrationService.getById(id)));
    }

    @PostMapping
    @Operation(summary = "Create registration and applicant user account (so user can log in)")
    public ResponseEntity<Registration> create(@RequestBody RegistrationCreateRequest request) {
        Registration created = registrationService.create(request);
        return ResponseEntity.ok(created);
    }

    @PatchMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update registration status (admin)")
    public ResponseEntity<Void> updateStatus(@PathVariable UUID id, @RequestBody StatusUpdate status) {
        registrationService.updateStatus(id, status.getStatus());
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/toggle-enabled")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle user account enabled/disabled for a registration (admin)")
    public ResponseEntity<java.util.Map<String, Boolean>> toggleEnabled(@PathVariable UUID id) {
        boolean enabled = registrationService.toggleEnabled(id);
        return ResponseEntity.ok(java.util.Map.of("enabled", enabled));
    }

    @lombok.Data
    public static class StatusUpdate {
        private RegistrationStatus status;
    }
}
