package com.sidbi.vdf.service;

import com.sidbi.vdf.domain.Application;
import com.sidbi.vdf.domain.AuditEntry;
import com.sidbi.vdf.domain.FieldComment;
import com.sidbi.vdf.domain.enums.*;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.*;
import java.util.UUID;

/**
 * Finite state machine for application workflow.
 * Matches vdf-ui/src/lib/applicationStore.ts (workflowTransitions, actionTransitions, status/stage derivation).
 */
@Component
public class WorkflowEngine {

    /** State → allowed actions. Only these actions are valid from each step. */
    private static final Map<WorkflowStep, List<WorkflowAction>> WORKFLOW_TRANSITIONS = Map.ofEntries(
        entry(WorkflowStep.prelim_review, Arrays.asList(WorkflowAction.revert_prelim, WorkflowAction.reject_prelim, WorkflowAction.approve_prelim)),
        entry(WorkflowStep.prelim_submitted, Arrays.asList(WorkflowAction.revert_prelim, WorkflowAction.reject_prelim, WorkflowAction.approve_prelim)),
        entry(WorkflowStep.prelim_revision, list()),
        entry(WorkflowStep.prelim_rejected, list()),
        entry(WorkflowStep.detailed_form, list()),
        entry(WorkflowStep.detailed_form_open, list()),
        entry(WorkflowStep.detailed_revision, list()),
        entry(WorkflowStep.detailed_maker_review, Arrays.asList(WorkflowAction.revert_detailed, WorkflowAction.recommend_rejection, WorkflowAction.recommend_pursual)),
        entry(WorkflowStep.detailed_checker_review, Arrays.asList(WorkflowAction.reject_final, WorkflowAction.recommend_icvd, WorkflowAction.recommend_ccic)),
        entry(WorkflowStep.detailed_rejected, list()),
        entry(WorkflowStep.icvd_maker_review, Arrays.asList(WorkflowAction.icvd_maker_forward)),
        entry(WorkflowStep.icvd_checker_review, Arrays.asList(WorkflowAction.icvd_checker_assign_convenor)),
        entry(WorkflowStep.icvd_convenor_scheduling, Arrays.asList(WorkflowAction.icvd_schedule_meeting)),
        entry(WorkflowStep.icvd_committee_review, Arrays.asList(WorkflowAction.icvd_committee_refer)),
        entry(WorkflowStep.icvd_referred, list()),
        entry(WorkflowStep.icvd_note_preparation, Arrays.asList(WorkflowAction.submit_icvd_note, WorkflowAction.icvd_maker_forward)),
        entry(WorkflowStep.ccic_maker_refine, Arrays.asList(WorkflowAction.ccic_maker_upload)),
        entry(WorkflowStep.ccic_checker_review, Arrays.asList(WorkflowAction.ccic_checker_forward_to_checker, WorkflowAction.ccic_checker_assign_convenor)),
        entry(WorkflowStep.ccic_second_checker_review, Arrays.asList(WorkflowAction.ccic_checker_assign_convenor)),
        entry(WorkflowStep.ccic_convenor_scheduling, Arrays.asList(WorkflowAction.ccic_schedule_meeting)),
        entry(WorkflowStep.ccic_committee_review, Arrays.asList(WorkflowAction.ccic_committee_refer)),
        entry(WorkflowStep.ccic_referred, list()),
        entry(WorkflowStep.ccic_maker_sanction, Arrays.asList(WorkflowAction.ccic_maker_sanction)),
        entry(WorkflowStep.ccic_note_preparation, Arrays.asList(WorkflowAction.submit_ccic_note, WorkflowAction.ccic_maker_upload)),
        entry(WorkflowStep.final_approval, Arrays.asList(WorkflowAction.approve_sanction, WorkflowAction.reject_sanction)),
        entry(WorkflowStep.final_rejected, list()),
        entry(WorkflowStep.sanctioned, list()),
        entry(WorkflowStep.completed, list())
    );

    /** Action → next step. */
    private static final Map<WorkflowAction, WorkflowStep> ACTION_TRANSITIONS = Map.ofEntries(
        map(WorkflowAction.revert_prelim, WorkflowStep.prelim_revision),
        map(WorkflowAction.reject_prelim, WorkflowStep.prelim_rejected),
        map(WorkflowAction.approve_prelim, WorkflowStep.detailed_form_open),
        map(WorkflowAction.revert_detailed, WorkflowStep.detailed_revision),
        map(WorkflowAction.recommend_rejection, WorkflowStep.detailed_checker_review),
        map(WorkflowAction.recommend_pursual, WorkflowStep.detailed_checker_review),
        map(WorkflowAction.reject_final, WorkflowStep.detailed_rejected),
        map(WorkflowAction.recommend_icvd, WorkflowStep.icvd_convenor_scheduling),
        map(WorkflowAction.recommend_ccic, WorkflowStep.ccic_maker_refine),
        map(WorkflowAction.icvd_maker_forward, WorkflowStep.icvd_checker_review),
        map(WorkflowAction.icvd_checker_assign_convenor, WorkflowStep.icvd_convenor_scheduling),
        map(WorkflowAction.icvd_schedule_meeting, WorkflowStep.icvd_committee_review),
        map(WorkflowAction.icvd_committee_refer, WorkflowStep.ccic_maker_refine),
        map(WorkflowAction.submit_icvd_note, WorkflowStep.icvd_checker_review),
        map(WorkflowAction.revert_icvd, WorkflowStep.icvd_maker_review),
        map(WorkflowAction.approve_icvd, WorkflowStep.icvd_convenor_scheduling),
        map(WorkflowAction.record_committee_decision, WorkflowStep.ccic_maker_refine),
        map(WorkflowAction.ccic_maker_upload, WorkflowStep.ccic_checker_review),
        map(WorkflowAction.ccic_checker_forward_to_checker, WorkflowStep.ccic_second_checker_review),
        map(WorkflowAction.ccic_checker_assign_convenor, WorkflowStep.ccic_convenor_scheduling),
        map(WorkflowAction.ccic_schedule_meeting, WorkflowStep.ccic_committee_review),
        map(WorkflowAction.ccic_committee_refer, WorkflowStep.ccic_maker_sanction),
        map(WorkflowAction.ccic_maker_sanction, WorkflowStep.sanctioned),
        map(WorkflowAction.submit_ccic_note, WorkflowStep.ccic_checker_review),
        map(WorkflowAction.revert_ccic, WorkflowStep.ccic_maker_refine),
        map(WorkflowAction.approve_ccic, WorkflowStep.final_approval),
        map(WorkflowAction.approve_sanction, WorkflowStep.sanctioned),
        map(WorkflowAction.reject_sanction, WorkflowStep.final_rejected)
    );

    private static Map.Entry<WorkflowStep, List<WorkflowAction>> entry(WorkflowStep step, List<WorkflowAction> actions) {
        return Map.entry(step, actions);
    }

    private static Map.Entry<WorkflowAction, WorkflowStep> map(WorkflowAction action, WorkflowStep step) {
        return Map.entry(action, step);
    }

    private static List<WorkflowAction> list() {
        return Collections.emptyList();
    }

    public boolean isValidTransition(WorkflowStep currentStep, WorkflowAction action) {
        return WORKFLOW_TRANSITIONS.getOrDefault(currentStep, Collections.emptyList()).contains(action);
    }

    public WorkflowStep nextStep(WorkflowAction action) {
        WorkflowStep next = ACTION_TRANSITIONS.get(action);
        if (next == null) {
            throw new IllegalArgumentException("Unknown workflow action: " + action);
        }
        return next;
    }

    /**
     * Apply the workflow action: validate, compute next step and status/stage, update entity, append audit.
     */
    public void apply(Application app, WorkflowAction action, String actorRole, String actorId,
                      String comment, String assignedChecker, String assignedConvenor, String assignedApprover,
                      RecommendedOutcome recommendedOutcome, UUID meetingId) {
        WorkflowStep current = app.getWorkflowStep();
        if (!isValidTransition(current, action)) {
            throw new IllegalStateException(
                "Invalid workflow transition: cannot perform \"" + action + "\" from step \"" + current + "\".");
        }
        WorkflowStep next = nextStep(action);
        app.setWorkflowStep(next);
        app.setUpdatedAt(Instant.now());

        if (assignedChecker != null) app.setAssignedChecker(assignedChecker);
        if (assignedConvenor != null) app.setAssignedConvenor(assignedConvenor);
        if (assignedApprover != null) app.setAssignedApprover(assignedApprover);
        if (recommendedOutcome != null) app.setRecommendedOutcome(recommendedOutcome);
        if (meetingId != null) {
            if (action.name().startsWith("icvd_")) app.setIcvdMeetingId(meetingId);
            if (action.name().startsWith("ccic_")) app.setCcicMeetingId(meetingId);
        }

        deriveStatusAndStage(app, action);

        if (app.getAuditTrail() == null) app.setAuditTrail(new ArrayList<>());
        app.getAuditTrail().add(AuditEntry.builder()
            .actorRole(actorRole)
            .actorId(actorId)
            .actionType(action.name())
            .remark(comment != null ? comment : "")
            .timestamp(Instant.now().toString())
            .build());

        if (comment != null && !comment.isBlank()) {
            Map<String, FieldComment> comments = app.getComments() != null ? new HashMap<>(app.getComments()) : new HashMap<>();
            comments.put("_global", FieldComment.builder()
                .needsChange(action.name().startsWith("revert"))
                .comment(comment)
                .build());
            app.setComments(comments);
        }
    }

    private void deriveStatusAndStage(Application app, WorkflowAction action) {
        switch (action) {
            case reject_prelim, reject_final, reject_sanction -> app.setStatus(AppStatus.rejected);
            case approve_sanction -> {
                app.setStatus(AppStatus.sanctioned);
                app.setStage(AppStage.post_sanction);
            }
            case approve_prelim -> {
                app.setStatus(AppStatus.approved);
                app.setStage(AppStage.detailed);
            }
            case recommend_pursual -> app.setStatus(AppStatus.recommend_pursual);
            case recommend_rejection -> app.setStatus(AppStatus.recommend_rejection);
            case revert_prelim, revert_detailed -> app.setStatus(AppStatus.reverted);
            case recommend_icvd -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.icvd);
            }
            case recommend_ccic -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.ccic);
            }
            case icvd_maker_forward, submit_icvd_note -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.icvd);
            }
            case icvd_checker_assign_convenor, approve_icvd -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.icvd);
            }
            case icvd_schedule_meeting -> {
                app.setStatus(AppStatus.under_review);
                app.setStage(AppStage.icvd);
            }
            case icvd_committee_refer, record_committee_decision -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.ccic);
            }
            case ccic_maker_upload, submit_ccic_note, ccic_checker_forward_to_checker -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.ccic);
            }
            case ccic_checker_assign_convenor, approve_ccic -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.ccic);
            }
            case ccic_schedule_meeting -> {
                app.setStatus(AppStatus.under_review);
                app.setStage(AppStage.ccic);
            }
            case ccic_committee_refer -> {
                app.setStatus(AppStatus.submitted);
                app.setStage(AppStage.ccic);
            }
            case ccic_maker_sanction -> {
                app.setStatus(AppStatus.sanctioned);
                app.setStage(AppStage.post_sanction);
            }
            default -> { /* no status/stage change */ }
        }
    }
}
