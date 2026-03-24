package com.sidbi.vdf.web;

import com.sidbi.vdf.domain.UserAccount;
import com.sidbi.vdf.domain.enums.SidbiRole;
import com.sidbi.vdf.repository.UserAccountRepository;
import com.sidbi.vdf.security.JwtTokenProvider;
import com.sidbi.vdf.service.EmailService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User accounts (admin only)")
public class UserAccountAdminController {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final EmailService emailService;

    // ── DTOs / Records ────────────────────────────────────────────────────────

    public record UserAccountDto(
        UUID id,
        String email,
        boolean enabled,
        boolean passwordSet,
        List<SidbiRole> roles,
        String setupLink   // non-null only on creation
    ) {}

    public record CreateUserRequest(
        String email,
        List<SidbiRole> roles
    ) {}

    public record UpdateRolesRequest(
        List<SidbiRole> roles
    ) {}

    public record EnableRequest(boolean enabled) {}

    // ── Endpoints ─────────────────────────────────────────────────────────────

    @GetMapping("/by-email")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Look up a user account by email")
    public ResponseEntity<UserAccountDto> getByEmail(@RequestParam String email) {
        return userAccountRepository.findByEmail(email.trim().toLowerCase())
            .map(this::toDto)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','SIDBI')")
    @Operation(summary = "List platform user accounts (excludes applicants)")
    public ResponseEntity<List<UserAccountDto>> list() {
        // Exclude applicants — identified by userType=applicant (set by registration flow)
        List<UserAccountDto> users = userAccountRepository.findAll()
            .stream()
            .filter(u -> u.getUserType() != com.sidbi.vdf.domain.enums.UserType.applicant)
            .map(this::toDto)
            .toList();
        return ResponseEntity.ok(users);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a user — sends password setup email")
    public ResponseEntity<UserAccountDto> create(@RequestBody CreateUserRequest body) {
        String email = body.email() != null ? body.email().trim().toLowerCase() : "";
        if (email.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        List<SidbiRole> roles = body.roles() != null ? body.roles() : List.of();
        if (roles.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        if (userAccountRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest().build();
        }

        boolean isAdmin = roles.stream().anyMatch(r -> r == SidbiRole.admin);
        SidbiRole primaryRole = isAdmin ? null : roles.get(0);
        String rolesStr = String.join(",", roles.stream().map(Enum::name).toList());

        UserAccount user = UserAccount.builder()
            .email(email)
            .passwordHash(passwordEncoder.encode(UUID.randomUUID().toString()))
            .userType(isAdmin
                ? com.sidbi.vdf.domain.enums.UserType.admin
                : com.sidbi.vdf.domain.enums.UserType.sidbi)
            .sidbiRole(primaryRole)
            .sidbiRoles(rolesStr)
            .enabled(false)
            .passwordSet(false)
            .build();

        UserAccount saved = userAccountRepository.save(user);

        String setupToken = jwtTokenProvider.createSetupToken(saved.getId().toString(), saved.getEmail());
        emailService.sendPasswordSetupEmail(saved.getEmail(), saved.getEmail(), setupToken);

        String setupLink = System.getenv().getOrDefault("VDF_APP_BASE_URL", "http://localhost:5173")
            + "/#/set-password/" + setupToken;
        return ResponseEntity.ok(toDtoWithLink(saved, setupLink));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Enable or disable a user")
    public ResponseEntity<UserAccountDto> setEnabled(
        @PathVariable UUID id,
        @RequestBody EnableRequest body
    ) {
        UserAccount user = userAccountRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        user.setEnabled(body.enabled());
        userAccountRepository.save(user);
        return ResponseEntity.ok(toDto(user));
    }

    @PatchMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update user roles")
    public ResponseEntity<UserAccountDto> updateRole(
        @PathVariable UUID id,
        @RequestBody UpdateRolesRequest body
    ) {
        List<SidbiRole> roles = body.roles() != null ? body.roles() : List.of();
        if (roles.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        UserAccount user = userAccountRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        boolean isAdmin = roles.stream().anyMatch(r -> r == SidbiRole.admin);
        user.setUserType(isAdmin
            ? com.sidbi.vdf.domain.enums.UserType.admin
            : com.sidbi.vdf.domain.enums.UserType.sidbi);
        user.setSidbiRole(isAdmin ? null : roles.get(0));
        user.setSidbiRoles(String.join(",", roles.stream().map(Enum::name).toList()));
        userAccountRepository.save(user);
        return ResponseEntity.ok(toDto(user));
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private UserAccountDto toDto(UserAccount u) {
        List<SidbiRole> roles = parseRoles(u.getSidbiRoles(), u.getSidbiRole());
        return new UserAccountDto(u.getId(), u.getEmail(), u.isEnabled(), u.isPasswordSet(), roles, null);
    }

    private UserAccountDto toDtoWithLink(UserAccount u, String setupLink) {
        List<SidbiRole> roles = parseRoles(u.getSidbiRoles(), u.getSidbiRole());
        return new UserAccountDto(u.getId(), u.getEmail(), u.isEnabled(), u.isPasswordSet(), roles, setupLink);
    }

    private static List<SidbiRole> parseRoles(String raw, SidbiRole fallback) {
        if (raw != null && !raw.isBlank()) {
            return java.util.Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(SidbiRole::valueOf)
                .toList();
        }
        return fallback != null ? List.of(fallback) : List.of();
    }
}
