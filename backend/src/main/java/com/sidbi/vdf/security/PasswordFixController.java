package com.sidbi.vdf.security;

import com.sidbi.vdf.domain.UserAccount;
import com.sidbi.vdf.repository.UserAccountRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/fix")
@RequiredArgsConstructor
@Slf4j
public class PasswordFixController {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/passwords")
    public String fixAllPasswords() {
        List<UserAccount> users = userAccountRepository.findAll();
        
        for (UserAccount user : users) {
            if (user.getEmail().endsWith("@demo.com")) {
                // Re-encode password "password" for all demo users
                String newHash = passwordEncoder.encode("password");
                user.setPasswordHash(newHash);
                user.setPasswordSet(true);
                user.setEnabled(true);
                userAccountRepository.save(user);
                log.info("Fixed password for: {}", user.getEmail());
            }
        }
        
        return "Fixed passwords for " + users.stream()
            .filter(u -> u.getEmail().endsWith("@demo.com"))
            .count() + " demo users";
    }
}
