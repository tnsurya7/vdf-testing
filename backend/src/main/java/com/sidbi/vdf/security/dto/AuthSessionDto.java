package com.sidbi.vdf.security.dto;

import com.sidbi.vdf.domain.enums.SidbiRole;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class AuthSessionDto {
    private String email;
    /** Currently active role for this session (null for admin/applicant). */
    private SidbiRole sidbiRole;
    /** All roles assigned to the user. */
    private List<SidbiRole> roles;
}
