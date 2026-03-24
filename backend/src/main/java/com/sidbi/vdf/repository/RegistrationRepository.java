package com.sidbi.vdf.repository;

import com.sidbi.vdf.domain.Registration;
import com.sidbi.vdf.domain.enums.RegistrationStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface RegistrationRepository extends JpaRepository<Registration, UUID> {

    List<Registration> findAllByOrderBySubmittedAtDesc();

    List<Registration> findByStatus(RegistrationStatus status);
}
