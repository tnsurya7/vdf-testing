package com.sidbi.vdf.web.dto;

import com.sidbi.vdf.domain.enums.RecommendedOutcome;
import com.sidbi.vdf.domain.enums.WorkflowAction;
import lombok.Data;

import java.util.UUID;

@Data
public class WorkflowActionRequest {
    private WorkflowAction action;
    private ActorDto actor;
    private String comment;
    private String assignedChecker;
    private String assignedConvenor;
    private String assignedApprover;
    private RecommendedOutcome recommendedOutcome;
    private UUID meetingId;

    @Data
    public static class ActorDto {
        private String role;
        private String id;
    }
}
