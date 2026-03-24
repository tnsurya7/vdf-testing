package com.sidbi.vdf.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Per-application decision captured by convenor when sending the meeting for committee consent.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationDecision implements Serializable {

    @JsonProperty("applicationId")
    private UUID applicationId;

    @JsonProperty("approved")
    private Boolean approved;

    /** Approved amount (e.g. in INR); null or zero when not approved. */
    @JsonProperty("approvedAmount")
    private BigDecimal approvedAmount;
}
