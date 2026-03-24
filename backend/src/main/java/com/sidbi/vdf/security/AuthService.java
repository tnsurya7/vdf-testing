package com.sidbi.vdf.security;

import com.sidbi.vdf.domain.UserAccount;
import com.sidbi.vdf.domain.enums.SidbiRole;
import com.sidbi.vdf.repository.UserAccountRepository;
import com.sidbi.vdf.security.dto.AuthSessionDto;
import com.sidbi.vdf.security.dto.LoginResponse;
import com.sidbi.vdf.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final EmailService emailService;

    private static List<SidbiRole> parseRoles(String raw, SidbiRole fallback) {
        if (raw != null && !raw.isBlank()) {
            return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(SidbiRole::valueOf)
                .collect(Collectors.toList());
        }
        return fallback != null ? Collections.singletonList(fallback) : Collections.emptyList();
    }

    private static AuthSessionDto toSessionDto(UserAccount user, SidbiRole activeRole) {
        List<SidbiRole> roles = parseRoles(user.getSidbiRoles(), user.getSidbiRole());
        return AuthSessionDto.builder()
            .email(user.getEmail())
            .sidbiRole(activeRole)
            .roles(roles)
            .build();
    }

    public LoginResponse login(String email, String password) {
        UserAccount user = userAccountRepository.findByEmailAndEnabledTrue(email)
            .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));
        if (!user.isPasswordSet()) {
            throw new BadCredentialsException("Password not set. Please check your email for the setup link.");
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid email or password");
        }
        List<SidbiRole> roles = parseRoles(user.getSidbiRoles(), user.getSidbiRole());
        SidbiRole activeRole = roles.stream()
            .filter(r -> r != SidbiRole.admin)
            .findFirst()
            .orElse(null);
        String token = jwtTokenProvider.createAccessToken(
            user.getId().toString(),
            user.getEmail(),
            roles,
            activeRole
        );
        return LoginResponse.builder()
            .accessToken(token)
            .user(toSessionDto(user, activeRole))
            .build();
    }

    public AuthSessionDto sessionFromEmail(String email) {
        UserAccount user = userAccountRepository.findByEmailAndEnabledTrue(email)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        List<SidbiRole> roles = parseRoles(user.getSidbiRoles(), user.getSidbiRole());
        SidbiRole activeRole = roles.stream()
            .filter(r -> r != SidbiRole.admin)
            .findFirst()
            .orElse(null);
        return toSessionDto(user, activeRole);
    }

    public LoginResponse switchRole(String email, SidbiRole role) {
        UserAccount user = userAccountRepository.findByEmailAndEnabledTrue(email)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        List<SidbiRole> allowed = parseRoles(user.getSidbiRoles(), user.getSidbiRole());
        if (!allowed.contains(role)) {
            throw new IllegalArgumentException("User does not have role: " + role);
        }
        String token = jwtTokenProvider.createAccessToken(
            user.getId().toString(),
            user.getEmail(),
            allowed,
            role
        );
        AuthSessionDto session = AuthSessionDto.builder()
            .email(user.getEmail())
            .sidbiRole(role)
            .roles(allowed)
            .build();
        return LoginResponse.builder()
            .accessToken(token)
            .user(session)
            .build();
    }

    public void forgotPassword(String email) {
        userAccountRepository.findByEmail(email.trim().toLowerCase()).ifPresent(user -> {
            String token = jwtTokenProvider.createSetupToken(user.getId().toString(), user.getEmail());
            emailService.sendPasswordResetEmail(user.getEmail(), user.getEmail(), token);
            log.info("Password reset email sent to: {}", user.getEmail());
        });
    }

    public void setPasswordFromToken(String token, String rawPassword) {
        JwtTokenProvider.JwtClaims claims;
        try {
            claims = jwtTokenProvider.parseToken(token);
        } catch (Exception e) {
            throw new BadCredentialsException("Invalid or expired setup link.");
        }
        UUID userId = UUID.fromString(claims.sub());
        UserAccount user = userAccountRepository.findById(userId)
            .orElseThrow(() -> new BadCredentialsException("User not found."));
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        user.setPasswordSet(true);
        user.setEnabled(true);
        userAccountRepository.save(user);
    }
}