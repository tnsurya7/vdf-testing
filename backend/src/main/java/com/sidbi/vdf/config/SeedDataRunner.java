package com.sidbi.vdf.config;

import com.sidbi.vdf.repository.UserAccountRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * On startup, ensures the two bootstrap admin accounts have a valid password hash.
 * This runs once and is safe to leave in — it only touches accounts that exist.
 */
@Component
@Order(1)
@RequiredArgsConstructor
@Slf4j
public class SeedDataRunner implements ApplicationRunner {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    private static final List<String> BOOTSTRAP_EMAILS = List.of(
        "portaladminvdf@gmail.com",
        "sidbicheckervdf@gmail.com"
    );

    @Override
    public void run(ApplicationArguments args) {
        long total = userAccountRepository.count();
        log.info("VDF startup: {} user account(s) in database.", total);

        String encoded = passwordEncoder.encode("admin@1234");
        for (String email : BOOTSTRAP_EMAILS) {
            userAccountRepository.findByEmail(email).ifPresent(u -> {
                u.setPasswordHash(encoded);
                u.setPasswordSet(true);
                u.setEnabled(true);
                userAccountRepository.save(u);
                log.info("Bootstrap password set for: {}", email);
            });
        }
    }
}