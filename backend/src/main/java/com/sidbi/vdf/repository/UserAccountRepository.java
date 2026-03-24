package com.sidbi.vdf.repository;

import com.sidbi.vdf.domain.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserAccountRepository extends JpaRepository<UserAccount, UUID> {

    Optional<UserAccount> findByEmailAndEnabledTrue(String email);

    Optional<UserAccount> findByEmail(String email);
}
