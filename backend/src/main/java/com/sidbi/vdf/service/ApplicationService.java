package com.sidbi.vdf.service;

import com.sidbi.vdf.domain.Application;
import com.sidbi.vdf.domain.ApplicationDecision;
import com.sidbi.vdf.domain.CommitteeMeeting;
import com.sidbi.vdf.domain.enums.*;
import com.sidbi.vdf.repository.ApplicationRepository;
import com.sidbi.vdf.web.dto.CommitteeDecisionDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ApplicationService {

    private final ApplicationRepository applicationRepository;
    private final WorkflowEngine workflowEngine;
    private final CommitteeMeetingService committeeMeetingService;

    public List<Application> listByApplicant(String email) {
        return applicationRepository.findByApplicantEmailOrderByUpdatedAtDesc(email);
    }

    public List<Application> listByRole(com.sidbi.vdf.domain.enums.SidbiRole role) {
        if (role == null) return applicationRepository.findAllByOrderByUpdatedAtDesc();
        List<WorkflowStep> steps = workflowStepsForRole(role);
        return applicationRepository.findAllByOrderByUpdatedAtDesc().stream()
            .filter(app -> steps.contains(app.getWorkflowStep()))
            .toList();
    }

    public List<Application> listAll() {
        return applicationRepository.findAllByOrderByUpdatedAtDesc();
    }

    /** Workflow steps visible to a SIDBI role (align with vdf-ui mock filter). */
    private static java.util.List<WorkflowStep> workflowStepsForRole(com.sidbi.vdf.domain.enums.SidbiRole role) {
        return switch (role) {
            case convenor -> List.of(
                WorkflowStep.icvd_maker_review, WorkflowStep.icvd_checker_review, WorkflowStep.icvd_convenor_scheduling,
                WorkflowStep.icvd_committee_review, WorkflowStep.icvd_referred,
                WorkflowStep.ccic_maker_refine, WorkflowStep.ccic_checker_review, WorkflowStep.ccic_convenor_scheduling,
                WorkflowStep.ccic_committee_review);
            case checker -> List.of(
                WorkflowStep.detailed_checker_review,
                WorkflowStep.icvd_maker_review, WorkflowStep.icvd_checker_review, WorkflowStep.icvd_convenor_scheduling,
                WorkflowStep.icvd_committee_review, WorkflowStep.icvd_referred,
                WorkflowStep.ccic_maker_refine, WorkflowStep.ccic_checker_review, WorkflowStep.ccic_second_checker_review,
                WorkflowStep.ccic_convenor_scheduling, WorkflowStep.ccic_committee_review);
            case icvd_committee_member -> List.of(
                WorkflowStep.icvd_committee_review,
                WorkflowStep.icvd_referred,
                WorkflowStep.icvd_note_preparation);
            case ccic_committee_member -> List.of(
                WorkflowStep.ccic_committee_review,
                WorkflowStep.ccic_referred,
                WorkflowStep.ccic_note_preparation,
                WorkflowStep.ccic_maker_sanction);
            default -> List.of(WorkflowStep.values()); // maker, legacy committee_member, approving_authority see all
        };
    }

    public Application getById(UUID id) {
        return applicationRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Application not found: " + id));
    }

    /** Committee decision for this application (from IC-VD or CCIC meeting), if any. */
    public Optional<CommitteeDecisionDto> getCommitteeDecision(UUID applicationId) {
        Application app = getById(applicationId);
        UUID meetingId = app.getIcvdMeetingId() != null ? app.getIcvdMeetingId() : app.getCcicMeetingId();
        if (meetingId == null) return Optional.empty();
        CommitteeMeeting meeting = committeeMeetingService.getById(meetingId);
        if (meeting.getApplicationDecisions() == null) return Optional.empty();
        return meeting.getApplicationDecisions().stream()
            .filter(d -> d != null && applicationId.equals(d.getApplicationId()))
            .findFirst()
            .map(d -> CommitteeDecisionDto.builder()
                .approved(d.getApproved())
                .approvedAmount(d.getApprovedAmount())
                .build());
    }

    @Transactional
    public Application createPrelim(String email, Map<String, Object> prelimData) {
        Application app = Application.builder()
            .applicantEmail(email)
            .status(AppStatus.submitted)
            .stage(AppStage.prelim)
            .workflowStep(WorkflowStep.prelim_submitted)
            .prelimData(prelimData)
            .detailedData(null)
            .comments(new java.util.HashMap<>())
            .auditTrail(List.of(
                com.sidbi.vdf.domain.AuditEntry.builder()
                    .actorRole("applicant")
                    .actorId(email)
                    .actionType("submit")
                    .remark("Preliminary application submitted")
                    .timestamp(Instant.now().toString())
                    .build()
            ))
            .submittedAt(Instant.now())
            .updatedAt(Instant.now())
            .build();
        return applicationRepository.save(app);
    }

    @Transactional
    public void updatePrelim(UUID id, Map<String, Object> prelimData) {
        Application app = getById(id);
        app.setPrelimData(prelimData);
        app.setStatus(AppStatus.submitted);
        app.setWorkflowStep(WorkflowStep.prelim_submitted);
        app.setComments(new java.util.HashMap<>());
        app.setUpdatedAt(Instant.now());
        applicationRepository.save(app);
    }

    @Transactional
    public void submitDetailed(UUID appId, Map<String, Object> detailedData) {
        Application app = getById(appId);
        app.setStage(AppStage.detailed);
        app.setStatus(AppStatus.submitted);
        app.setWorkflowStep(WorkflowStep.detailed_maker_review);
        app.setDetailedData(detailedData);
        app.setComments(new java.util.HashMap<>());
        app.setUpdatedAt(Instant.now());
        applicationRepository.save(app);
    }

    @Transactional
    public void applyWorkflowAction(UUID id, WorkflowAction action, String actorRole, String actorId,
                                   String comment, String assignedChecker, String assignedConvenor,
                                   String assignedApprover, RecommendedOutcome recommendedOutcome, UUID meetingId) {
        Application app = getById(id);
        workflowEngine.apply(app, action, actorRole, actorId, comment, assignedChecker, assignedConvenor,
            assignedApprover, recommendedOutcome, meetingId);
        applicationRepository.save(app);
    }

    @Transactional
    public void updateIcvdNote(UUID applicationId, Map<String, Object> icvdNote) {
        Application app = getById(applicationId);
        app.setIcvdNote(icvdNote);
        app.setUpdatedAt(Instant.now());
        applicationRepository.save(app);
    }

    @Transactional
    public void updateCcicNote(UUID applicationId, Map<String, Object> ccicNote) {
        Application app = getById(applicationId);
        app.setCcicNote(ccicNote);
        app.setUpdatedAt(Instant.now());
        applicationRepository.save(app);
    }

    @Transactional
    public void delete(UUID id) {
        if (!applicationRepository.existsById(id)) {
            throw new IllegalArgumentException("Application not found: " + id);
        }
        applicationRepository.deleteById(id);
    }
}
