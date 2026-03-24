package com.sidbi.vdf.domain;

import com.sidbi.vdf.domain.enums.SidbiRole;
import com.sidbi.vdf.domain.enums.UserType;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "vdf_user_account")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_type", nullable = false)
    private UserType userType;

    @Enumerated(EnumType.STRING)
    @Column(name = "sidbi_role")
    private SidbiRole sidbiRole;

    /**
     * Comma-separated list of all SIDBI roles assigned to the user (for admin management).
     * The primary / active role for a session is still taken from sidbiRole.
     */
    @Column(name = "sidbi_roles")
    private String sidbiRoles;

    @Column(nullable = false)
    @Builder.Default
    private boolean enabled = true;

    /** True once the user has set their password via the setup link. */
    @Column(name = "password_set", nullable = false)
    @Builder.Default
    private boolean passwordSet = false;
}
