package com.sidbi.vdf.security;

import com.sidbi.vdf.security.dto.AuthSessionDto;
import com.sidbi.vdf.security.dto.LoginRequest;
import com.sidbi.vdf.security.dto.LoginResponse;
import com.sidbi.vdf.security.dto.SwitchRoleRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Auth", description = "Authentication endpoints")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/forgot-password")
    @Operation(summary = "Request password reset link — always returns 200 to prevent email enumeration")
    public ResponseEntity<Void> forgotPassword(@RequestBody java.util.Map<String, String> body) {
        String email = body.get("email");
        if (email != null && !email.isBlank()) {
            authService.forgotPassword(email);
        }
        // Always return 200 to prevent email enumeration
        return ResponseEntity.ok().build();
    }

    @PostMapping("/set-password")
    @Operation(summary = "Set password via setup token (from email link)")
    public ResponseEntity<Void> setPassword(@RequestBody java.util.Map<String, String> body) {
        String token = body.get("token");
        String password = body.get("password");
        if (token == null || token.isBlank() || password == null || password.length() < 8) {
            return ResponseEntity.badRequest().build();
        }
        authService.setPasswordFromToken(token, password);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    @Operation(summary = "Login", description = "Authenticate with email and password, returns JWT and user session")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request.getEmail(), request.getPassword());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    @Operation(summary = "Current session", description = "Returns current user session (email, userType, sidbiRole, roles)")
    public ResponseEntity<AuthSessionDto> me(@AuthenticationPrincipal String principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        AuthSessionDto session = authService.sessionFromEmail(principal);
        return ResponseEntity.ok(session);
    }

    @PostMapping("/switch-role")
    @Operation(summary = "Switch role", description = "Switch acting SIDBI role; returns new JWT and session. User must have the requested role.")
    public ResponseEntity<LoginResponse> switchRole(
        @AuthenticationPrincipal String principal,
        @Valid @RequestBody SwitchRoleRequest request
    ) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        LoginResponse response = authService.switchRole(principal, request.getRole());
        return ResponseEntity.ok(response);
    }
}
