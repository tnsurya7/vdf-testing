package com.sidbi.vdf.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
public class CorsConfig {

    @Value("${vdf.cors.allowed-origins:http://localhost:5173,http://localhost:8080}")
    private String allowedOrigins;

    /** Optional. If set (e.g. in UAT), allows patterns like https://*.github.io. Takes precedence over allowed-origins when non-empty. */
    @Value("${vdf.cors.allowed-origin-patterns:}")
    private String allowedOriginPatterns;

    @Value("${vdf.cors.allowed-methods:GET,POST,PUT,PATCH,DELETE,OPTIONS}")
    private String allowedMethods;

    @Value("${vdf.cors.allowed-headers:Authorization,Content-Type}")
    private String allowedHeaders;

    @Value("${vdf.cors.allow-credentials:true}")
    private boolean allowCredentials;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        String patterns = allowedOriginPatterns != null ? allowedOriginPatterns.trim() : "";
        if (!patterns.isEmpty()) {
            config.setAllowedOriginPatterns(List.of(patterns.split(",")));
        } else {
            config.setAllowedOrigins(List.of(allowedOrigins.split(",")));
        }
        config.setAllowedMethods(List.of(allowedMethods.split(",")));
        config.setAllowedHeaders(List.of(allowedHeaders.split(",")));
        config.setAllowCredentials(allowCredentials);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
