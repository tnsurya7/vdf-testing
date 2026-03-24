package com.sidbi.vdf.security;

import com.sidbi.vdf.config.JwtProperties;
import com.sidbi.vdf.domain.enums.SidbiRole;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    private final JwtProperties jwtProperties;

    private SecretKey getSigningKey() {
        String secret = jwtProperties.getSecret();
        if (secret == null || secret.length() < 32) {
            throw new IllegalStateException("vdf.jwt.secret must be set and at least 32 characters");
        }
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String createSetupToken(String userId, String email) {
        SecretKey key = getSigningKey();
        Date now = new Date();
        return Jwts.builder()
            .subject(userId)
            .issuer(jwtProperties.getIssuer())
            .issuedAt(now)
            .expiration(new Date(now.getTime() + 15 * 60_000L))
            .claim("email", email)
            .claim("purpose", "setup")
            .signWith(key)
            .compact();
    }

    /**
     * Creates an access token. roles is the full list of assigned roles;
     * activeRole is the currently active role for this session (may be null for applicants).
     */
    public String createAccessToken(String subject, String email, List<SidbiRole> roles, SidbiRole activeRole) {
        SecretKey key = getSigningKey();
        Date now = new Date();
        var builder = Jwts.builder()
            .subject(subject)
            .issuer(jwtProperties.getIssuer())
            .issuedAt(now)
            .expiration(new Date(now.getTime() + jwtProperties.getAccessTokenValidityMinutes() * 60_000L))
            .claim("email", email)
            .claim("roles", roles.stream().map(Enum::name).toList())
            .signWith(key);
        if (activeRole != null) {
            builder.claim("sidbiRole", activeRole.name());
        }
        return builder.compact();
    }

    @SuppressWarnings("unchecked")
    public JwtClaims parseToken(String token) {
        SecretKey key = getSigningKey();
        Claims claims = Jwts.parser()
            .verifyWith(key)
            .requireIssuer(jwtProperties.getIssuer())
            .build()
            .parseSignedClaims(token)
            .getPayload();
        String email = claims.get("email", String.class);
        String sidbiRoleStr = claims.get("sidbiRole", String.class);
        List<String> roleStrs = claims.get("roles", List.class);
        List<SidbiRole> roles = roleStrs != null
            ? roleStrs.stream().map(SidbiRole::valueOf).toList()
            : List.of();
        SidbiRole activeRole = sidbiRoleStr != null ? SidbiRole.valueOf(sidbiRoleStr) : null;
        return new JwtClaims(
            claims.getSubject(),
            email != null ? email : claims.getSubject(),
            roles,
            activeRole
        );
    }

    public boolean validateToken(String token) {
        try { parseToken(token); return true; }
        catch (JwtException e) { return false; }
    }

    public record JwtClaims(String sub, String email, List<SidbiRole> roles, SidbiRole sidbiRole) {}
}
