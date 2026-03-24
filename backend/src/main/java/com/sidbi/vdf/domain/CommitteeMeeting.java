package com.sidbi.vdf.domain;

import com.sidbi.vdf.domain.enums.MeetingOutcome;
import com.sidbi.vdf.domain.enums.MeetingStatus;
import com.sidbi.vdf.domain.enums.MeetingType;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "vdf_committee_meeting")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommitteeMeeting {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MeetingType type;

    @Column(nullable = false)
    private String subject;

    @Column(name = "meeting_number", nullable = false)
    private Integer meetingNumber;

    @Column(name = "date_time", nullable = false)
    private String dateTime;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "total_members", columnDefinition = "jsonb")
    @Builder.Default
    private List<CommitteeMember> totalMembers = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "selected_members", columnDefinition = "jsonb")
    @Builder.Default
    private List<CommitteeMember> selectedMembers = new ArrayList<>();

    @Column(name = "maker_email", nullable = false)
    private String makerEmail;

    @Column(name = "checker_email", nullable = false)
    private String checkerEmail;

    @Column(name = "convenor_email", nullable = false)
    private String convenorEmail;

    @Column(name = "approver_email")
    private String approverEmail;

    @Column(name = "chair_person_email")
    @JsonProperty("chairPersonEmail")
    private String chairPersonEmail;

    @Column(name = "minutes_file_id")
    private UUID minutesFileId;

    @Column(name = "minutes_file_name", length = 500)
    private String minutesFileName;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "application_ids", columnDefinition = "jsonb")
    @Builder.Default
    private List<UUID> applicationIds = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "application_decisions", columnDefinition = "jsonb")
    @Builder.Default
    private List<ApplicationDecision> applicationDecisions = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MeetingStatus status;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    @Builder.Default
    private List<MeetingVote> votes = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    private MeetingOutcome outcome;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
