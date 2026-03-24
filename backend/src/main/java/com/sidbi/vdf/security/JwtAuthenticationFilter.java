package com.sidbi.vdf.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        String token = extractToken(request);
        if (StringUtils.hasText(token) && jwtTokenProvider.validateToken(token)) {
            try {
                JwtTokenProvider.JwtClaims claims = jwtTokenProvider.parseToken(token);
                List<SimpleGrantedAuthority> authorities = new ArrayList<>();

                boolean isAdmin = claims.roles().stream()
                    .anyMatch(r -> r == com.sidbi.vdf.domain.enums.SidbiRole.admin);

                if (isAdmin) {
                    authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
                } else if (!claims.roles().isEmpty()) {
                    authorities.add(new SimpleGrantedAuthority("ROLE_SIDBI"));
                } else {
                    authorities.add(new SimpleGrantedAuthority("ROLE_APPLICANT"));
                }

                if (claims.sidbiRole() != null) {
                    authorities.add(new SimpleGrantedAuthority("SIDBI_" + claims.sidbiRole().name().toUpperCase()));
                }

                var auth = new UsernamePasswordAuthenticationToken(
                    claims.email(),
                    null,
                    authorities
                );
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (Exception e) {
                SecurityContextHolder.clearContext();
            }
        }
        filterChain.doFilter(request, response);
    }

    private String extractToken(HttpServletRequest request) {
        String bearer = request.getHeader("Authorization");
        if (StringUtils.hasText(bearer) && bearer.startsWith("Bearer ")) {
            return bearer.substring(7);
        }
        String xAuth = request.getHeader("X-Authorization");
        if (StringUtils.hasText(xAuth) && xAuth.startsWith("Bearer ")) {
            return xAuth.substring(7);
        }
        return null;
    }
}
