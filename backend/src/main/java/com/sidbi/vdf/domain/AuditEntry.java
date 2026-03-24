package com.sidbi.vdf.domain;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditEntry implements Serializable {
    private String actorRole;
    private String actorId;
    private String actionType;
    private String remark;
    private String timestamp;
}
