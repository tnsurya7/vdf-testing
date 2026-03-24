package com.sidbi.vdf.web.dto;

import com.sidbi.vdf.domain.MeetingVote;
import lombok.Data;

import java.util.UUID;

/**
 * Request body for adding a vote. UI may send { meetingId, vote } (meetingId optional when using path).
 */
@Data
public class AddVoteRequest {
    private UUID meetingId;
    private MeetingVote vote;
}
