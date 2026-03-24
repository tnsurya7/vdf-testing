package com.sidbi.vdf.repository;

import com.sidbi.vdf.domain.CommitteeMeeting;
import com.sidbi.vdf.domain.enums.MeetingType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CommitteeMeetingRepository extends JpaRepository<CommitteeMeeting, UUID> {

    List<CommitteeMeeting> findByTypeOrderByMeetingNumberDesc(MeetingType type);

    List<CommitteeMeeting> findAllByOrderByUpdatedAtDesc();
}
