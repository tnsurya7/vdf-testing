package com.sidbi.vdf.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Getter;
import lombok.Setter;

@ConfigurationProperties(prefix = "vdf.jwt")
@Component
@Getter
@Setter
public class JwtProperties {
    private String secret;
    private int accessTokenValidityMinutes = 60;
    private String issuer = "vdf-backend";
}
