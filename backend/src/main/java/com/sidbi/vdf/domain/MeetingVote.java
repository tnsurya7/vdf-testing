package com.sidbi.vdf.domain;

import com.sidbi.vdf.domain.enums.VoteType;
import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MeetingVote implements Serializable {
    private String memberId;
    private VoteType vote;
    private String comment;
    private String timestamp;
}
