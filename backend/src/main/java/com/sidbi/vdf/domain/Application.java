package com.sidbi.vdf.domain;

import com.sidbi.vdf.domain.enums.AppStage;
import com.sidbi.vdf.domain.enums.AppStatus;
import com.sidbi.vdf.domain.enums.RecommendedOutcome;
import com.sidbi.vdf.domain.enums.WorkflowStep;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "VDF_application")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Application {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "applicant_email", nullable = false)
    private String applicantEmail;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AppStatus status;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AppStage stage;

    @Enumerated(EnumType.STRING)
    @Column(name = "workflow_step", nullable = false)
    private WorkflowStep workflowStep;

    @Column(name = "assigned_maker")
    private String assignedMaker;

    @Column(name = "assigned_checker")
    private String assignedChecker;

    @Column(name = "assigned_convenor")
    private String assignedConvenor;

    @Column(name = "assigned_approver")
    private String assignedApprover;

    @Enumerated(EnumType.STRING)
    @Column(name = "recommended_outcome")
    private RecommendedOutcome recommendedOutcome;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "prelim_data", columnDefinition = "jsonb")
    private Map<String, Object> prelimData;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "detailed_data", columnDefinition = "jsonb")
    private Map<String, Object> detailedData;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "icvd_note", columnDefinition = "jsonb")
    private Map<String, Object> icvdNote;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "ccic_note", columnDefinition = "jsonb")
    private Map<String, Object> ccicNote;

    @Column(name = "icvd_meeting_id")
    private UUID icvdMeetingId;

    @Column(name = "ccic_meeting_id")
    private UUID ccicMeetingId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    @Builder.Default
    private Map<String, FieldComment> comments = new HashMap<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "audit_trail", columnDefinition = "jsonb")
    @Builder.Default
    private List<AuditEntry> auditTrail = new ArrayList<>();

    @Column(name = "submitted_at", nullable = false)
    private Instant submittedAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
