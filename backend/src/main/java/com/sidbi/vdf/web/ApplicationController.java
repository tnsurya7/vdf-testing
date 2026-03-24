package com.sidbi.vdf.web;

import com.sidbi.vdf.domain.Application;
import com.sidbi.vdf.domain.enums.SidbiRole;
import com.sidbi.vdf.service.ApplicationService;
import com.sidbi.vdf.web.dto.CommitteeDecisionDto;
import com.sidbi.vdf.web.dto.WorkflowActionRequest;
import com.sidbi.vdf.web.dto.WorkflowActionResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;

@RestController
@RequestMapping("/api/applications")
@RequiredArgsConstructor
@Tag(name = "Applications", description = "Venture debt application workflow")
public class ApplicationController {

    private final ApplicationService applicationService;

    @GetMapping
    @Operation(summary = "List applications (filtered by user/role on server)")
    public ResponseEntity<List<Application>> list(
        @RequestParam(required = false) String email,
        @RequestParam(required = false) SidbiRole role,
        @AuthenticationPrincipal String principal
    ) {
        String user = principal;
        if (email != null) {
            return ResponseEntity.ok(applicationService.listByApplicant(email));
        }
        if (role != null) {
            return ResponseEntity.ok(applicationService.listByRole(role));
        }
        if (user != null) {
            return ResponseEntity.ok(applicationService.listByApplicant(user));
        }
        return ResponseEntity.ok(applicationService.listAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get application by ID")
    public ResponseEntity<Application> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(applicationService.getById(id));
    }

    @GetMapping("/{id}/committee-decision")
    @Operation(summary = "Get committee decision for application (approved, approvedAmount) if set")
    public ResponseEntity<CommitteeDecisionDto> getCommitteeDecision(@PathVariable UUID id) {
        return applicationService.getCommitteeDecision(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @PostMapping("/prelim")
    @Operation(summary = "Create preliminary application")
    public ResponseEntity<Application> createPrelim(
        @RequestBody PrelimCreate body,
        @AuthenticationPrincipal String principal
    ) {
        String email = principal != null ? principal : body.getEmail();
        if (email == null) email = body.getEmail();
        Application app = applicationService.createPrelim(email, body.getPrelimData());
        return ResponseEntity.ok(app);
    }

    @PutMapping("/{id}/prelim")
    @Operation(summary = "Update preliminary data")
    public ResponseEntity<Void> updatePrelim(@PathVariable UUID id, @RequestBody PrelimUpdate body) {
        applicationService.updatePrelim(id, body.getPrelimData());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/detailed")
    @Operation(summary = "Submit detailed application")
    public ResponseEntity<Void> submitDetailed(@PathVariable UUID id, @RequestBody DetailedSubmit body) {
        applicationService.submitDetailed(id, body.getDetailedData());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/workflow")
    @PreAuthorize("hasRole('SIDBI')")
    @Operation(summary = "Apply workflow action (SIDBI)")
    public ResponseEntity<WorkflowActionResponse> applyWorkflow(
        @PathVariable UUID id,
        @RequestBody WorkflowActionRequest body,
        @AuthenticationPrincipal String principal
    ) {
        String actorId = principal;
        String actorRole = body.getActor() != null ? body.getActor().getRole() : "sidbi";
        if (body.getActor() != null && body.getActor().getId() != null) {
            actorId = body.getActor().getId();
        }
        if (actorId == null) actorId = "unknown";
        try {
            applicationService.applyWorkflowAction(
                id,
                body.getAction(),
                actorRole,
                actorId,
                body.getComment(),
                body.getAssignedChecker(),
                body.getAssignedConvenor(),
                body.getAssignedApprover(),
                body.getRecommendedOutcome(),
                body.getMeetingId()
            );
            return ResponseEntity.ok(WorkflowActionResponse.builder().success(true).build());
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(WorkflowActionResponse.builder().success(false).error(e.getMessage()).build());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(WorkflowActionResponse.builder().success(false).error(e.getMessage()).build());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete application (admin or applicant owner)")
    public ResponseEntity<Void> delete(
        @PathVariable UUID id,
        @AuthenticationPrincipal String principal
    ) {
        Application app = applicationService.getById(id);
        String user = principal;
        boolean isAdmin = org.springframework.security.core.context.SecurityContextHolder.getContext()
            .getAuthentication().getAuthorities().stream()
            .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
        if (!isAdmin && (user == null || !app.getApplicantEmail().equals(user))) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).build();
        }
        applicationService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @lombok.Data
    public static class PrelimCreate {
        private String email;
        private Map<String, Object> prelimData;
    }

    @lombok.Data
    public static class PrelimUpdate {
        private Map<String, Object> prelimData;
    }

    @lombok.Data
    public static class DetailedSubmit {
        private String appId;
        private Map<String, Object> detailedData;
    }
}
