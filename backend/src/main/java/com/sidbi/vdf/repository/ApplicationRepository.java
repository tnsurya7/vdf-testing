package com.sidbi.vdf.repository;

import com.sidbi.vdf.domain.Application;
import com.sidbi.vdf.domain.enums.WorkflowStep;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ApplicationRepository extends JpaRepository<Application, UUID> {

    List<Application> findByApplicantEmailOrderByUpdatedAtDesc(String applicantEmail);

    List<Application> findAllByOrderByUpdatedAtDesc();

    List<Application> findByWorkflowStepIn(List<WorkflowStep> steps);
}
