package com.sidbi.vdf.service;

import com.sidbi.vdf.domain.Registration;
import com.sidbi.vdf.domain.UserAccount;
import com.sidbi.vdf.domain.enums.RegistrationStatus;
import com.sidbi.vdf.domain.enums.UserType;
import com.sidbi.vdf.repository.RegistrationRepository;
import com.sidbi.vdf.repository.UserAccountRepository;
import com.sidbi.vdf.web.dto.RegistrationCreateRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final RegistrationRepository registrationRepository;
    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    public List<Registration> list() {
        List<Registration> regs = registrationRepository.findAllByOrderBySubmittedAtDesc();
        regs.forEach(reg ->
            userAccountRepository.findByEmail(reg.getEmail())
                .ifPresent(user -> reg.setEnabled(user.isEnabled()))
        );
        return regs;
    }

    public Registration getById(UUID id) {
        return registrationRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Registration not found: " + id));
    }

    @Transactional
    public Registration create(RegistrationCreateRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (request.getPassword() == null || request.getPassword().isBlank()) {
            throw new IllegalArgumentException("Password is required");
        }
        if (userAccountRepository.findByEmail(request.getEmail().trim()).isPresent()) {
            throw new IllegalArgumentException("An account with this email already exists");
        }

        Registration registration = new Registration();
        registration.setId(null);
        registration.setEmail(request.getEmail().trim());
        registration.setNameOfApplicant(request.getNameOfApplicant());
        registration.setRegisteredOffice(request.getRegisteredOffice());
        registration.setLocationOfFacilities(request.getLocationOfFacilities());
        registration.setDateOfIncorporation(request.getDateOfIncorporation());
        registration.setDateOfCommencement(request.getDateOfCommencement());
        registration.setPanNo(request.getPanNo());
        registration.setGstNo(request.getGstNo());
        registration.setCin(request.getCin());
        registration.setMsmeStatus(request.getMsmeStatus());
        registration.setStatus(RegistrationStatus.pending);
        registration.setSubmittedAt(Instant.now());
        registration = registrationRepository.save(registration);

        UserAccount user = UserAccount.builder()
            .email(request.getEmail().trim())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .userType(UserType.applicant)
            .sidbiRole(null)
            .sidbiRoles(null)
            .enabled(false)
            .build();
        userAccountRepository.save(user);

        return registration;
    }

    @Transactional
    public void updateStatus(UUID id, RegistrationStatus status) {
        Registration reg = getById(id);
        reg.setStatus(status);
        registrationRepository.save(reg);

        if (status == RegistrationStatus.approved) {
            userAccountRepository.findByEmail(reg.getEmail()).ifPresent(user -> {
                user.setEnabled(true);
                userAccountRepository.save(user);
            });
        }
    }

    @Transactional
    public boolean toggleEnabled(UUID id) {
        Registration reg = getById(id);
        return userAccountRepository.findByEmail(reg.getEmail())
            .map(user -> {
                user.setEnabled(!user.isEnabled());
                userAccountRepository.save(user);
                return user.isEnabled();
            })
            .orElse(false);
    }
}
