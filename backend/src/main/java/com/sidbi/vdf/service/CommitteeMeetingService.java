package com.sidbi.vdf.service;

import com.sidbi.vdf.domain.ApplicationDecision;
import com.sidbi.vdf.domain.ApplicationFile;
import com.sidbi.vdf.domain.CommitteeMeeting;
import com.sidbi.vdf.domain.MeetingVote;
import com.sidbi.vdf.domain.enums.MeetingOutcome;
import com.sidbi.vdf.domain.enums.MeetingStatus;
import com.sidbi.vdf.domain.enums.MeetingType;
import com.sidbi.vdf.repository.CommitteeMeetingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommitteeMeetingService {

    private final CommitteeMeetingRepository committeeMeetingRepository;
    private final FileStorageService fileStorageService;

    public List<CommitteeMeeting> list(MeetingType type) {
        if (type != null) {
            return committeeMeetingRepository.findByTypeOrderByMeetingNumberDesc(type);
        }
        return committeeMeetingRepository.findAllByOrderByUpdatedAtDesc();
    }

    public CommitteeMeeting getById(UUID id) {
        return committeeMeetingRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Meeting not found: " + id));
    }

    @Transactional
    public CommitteeMeeting create(CommitteeMeeting meeting) {
        meeting.setId(null);
        meeting.setVotes(meeting.getVotes() != null ? meeting.getVotes() : new ArrayList<>());
        meeting.setApplicationDecisions(meeting.getApplicationDecisions() != null ? meeting.getApplicationDecisions() : new ArrayList<>());
        meeting.setCreatedAt(Instant.now());
        meeting.setUpdatedAt(Instant.now());
        // Ensure chair person is persisted (explicit set so Hibernate includes it in INSERT)
        String chairEmail = meeting.getChairPersonEmail();
        meeting.setChairPersonEmail(chairEmail);
        return committeeMeetingRepository.save(meeting);
    }

    @Transactional
    public void updateStatus(UUID id, MeetingStatus status, MeetingOutcome outcome, String dateTime,
                            List<ApplicationDecision> applicationDecisions) {
        CommitteeMeeting m = getById(id);
        if (status != null) {
            // When sending for consent, require one decision per application
            if (MeetingStatus.in_progress.equals(status) && MeetingStatus.scheduled.equals(m.getStatus())) {
                // No application decisions required at consent stage — just update status
            }
            // When convenor refers to further processing, at least one consent (approve vote) must exist
            if (MeetingStatus.completed.equals(status) && outcome != null && MeetingOutcome.referred.equals(outcome)) {
                boolean anyApproved = m.getVotes() != null && m.getVotes().stream()
                    .anyMatch(v -> com.sidbi.vdf.domain.enums.VoteType.approve.equals(v.getVote()));
                if (!anyApproved) {
                    throw new IllegalStateException("At least one committee member must consent before sending for further processing.");
                }
            }
            // When convenor pulls back from "sent for consent", clear votes so it can be re-sent
            if (MeetingStatus.scheduled.equals(status) && MeetingStatus.in_progress.equals(m.getStatus())) {
                m.setVotes(new ArrayList<>());
            }
            m.setStatus(status);
        }
        if (outcome != null) {
            m.setOutcome(outcome);
        }
        if (dateTime != null && !dateTime.isBlank()) {
            m.setDateTime(dateTime);
        }
        m.setUpdatedAt(Instant.now());
        committeeMeetingRepository.save(m);
    }

    @Transactional
    public void addVote(UUID meetingId, MeetingVote vote) {
        CommitteeMeeting m = getById(meetingId);
        if (m.getVotes() == null) m.setVotes(new ArrayList<>());
        if (vote.getTimestamp() == null) vote.setTimestamp(Instant.now().toString());
        m.getVotes().add(vote);
        m.setUpdatedAt(Instant.now());
        committeeMeetingRepository.save(m);
    }

    @Transactional
    public CommitteeMeeting uploadMinutes(UUID meetingId, MultipartFile file, String uploadedBy) {
        CommitteeMeeting m = getById(meetingId);
        if (!MeetingStatus.scheduled.equals(m.getStatus())) {
            throw new IllegalStateException("Minutes can only be uploaded before the meeting is sent for consent");
        }
        List<UUID> appIds = m.getApplicationIds();
        if (appIds == null || appIds.isEmpty()) {
            throw new IllegalArgumentException("Meeting has no linked applications");
        }
        UUID applicationId = appIds.get(0);
        ApplicationFile saved = fileStorageService.save(
            applicationId, "meeting_minutes", meetingId.toString(), file, uploadedBy);
        m.setMinutesFileId(saved.getId());
        m.setMinutesFileName(saved.getOriginalName() != null ? saved.getOriginalName() : "minutes.pdf");
        m.setUpdatedAt(Instant.now());
        return committeeMeetingRepository.save(m);
    }
}
