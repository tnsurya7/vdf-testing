package com.sidbi.vdf.web;

import com.sidbi.vdf.domain.ApplicationDecision;
import com.sidbi.vdf.domain.CommitteeMeeting;
import com.sidbi.vdf.domain.MeetingVote;
import com.sidbi.vdf.domain.enums.MeetingOutcome;
import com.sidbi.vdf.web.dto.AddVoteRequest;
import com.sidbi.vdf.domain.enums.MeetingStatus;
import com.sidbi.vdf.domain.enums.MeetingType;
import com.sidbi.vdf.service.CommitteeMeetingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/meetings")
@RequiredArgsConstructor
@Tag(name = "Meetings", description = "Committee meetings (IC-VD, CCIC)")
public class CommitteeMeetingController {

    private final CommitteeMeetingService committeeMeetingService;

    @GetMapping
    @Operation(summary = "List meetings", description = "Optional query param: type=icvd|ccic")
    public ResponseEntity<List<CommitteeMeeting>> list(@RequestParam(required = false) MeetingType type) {
        return ResponseEntity.ok(committeeMeetingService.list(type));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get meeting by ID")
    public ResponseEntity<CommitteeMeeting> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(committeeMeetingService.getById(id));
    }

    @PostMapping
    @Operation(summary = "Create meeting")
    public ResponseEntity<CommitteeMeeting> create(@RequestBody CommitteeMeeting meeting) {
        return ResponseEntity.ok(committeeMeetingService.create(meeting));
    }

    @PatchMapping("/{id}")
    @Operation(summary = "Update meeting status/outcome")
    public ResponseEntity<Void> updateStatus(
        @PathVariable UUID id,
        @RequestBody MeetingStatusUpdate body
    ) {
        committeeMeetingService.updateStatus(id, body.getStatus(), body.getOutcome(), body.getDateTime(), body.getApplicationDecisions());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/votes")
    @Operation(summary = "Add vote to meeting (body: { meetingId?, vote })")
    public ResponseEntity<Void> addVote(@PathVariable UUID id, @RequestBody AddVoteRequest body) {
        MeetingVote vote = body != null && body.getVote() != null ? body.getVote() : null;
        if (vote == null) {
            return ResponseEntity.badRequest().build();
        }
        committeeMeetingService.addVote(id, vote);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/minutes")
    @Operation(summary = "Upload minutes of the meeting")
    public ResponseEntity<CommitteeMeeting> uploadMinutes(
        @PathVariable UUID id,
        @RequestParam("file") MultipartFile file
    ) {
        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        String user = getPrincipalEmail();
        if (user == null) {
            return ResponseEntity.status(403).build();
        }
        CommitteeMeeting updated = committeeMeetingService.uploadMinutes(id, file, user);
        return ResponseEntity.ok(updated);
    }

    private static String getPrincipalEmail() {
        Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) return null;
        Object principal = auth.getPrincipal();
        return principal instanceof String ? (String) principal : null;
    }

    @lombok.Data
    public static class MeetingStatusUpdate {
        private MeetingStatus status;
        private MeetingOutcome outcome;
        private String dateTime;
        /** Required when setting status to in_progress (send for consent): one decision per application. */
        private List<ApplicationDecision> applicationDecisions;
    }
}
