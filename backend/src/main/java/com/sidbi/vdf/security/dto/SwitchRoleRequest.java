package com.sidbi.vdf.security.dto;

import com.sidbi.vdf.domain.enums.SidbiRole;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SwitchRoleRequest {
    @NotNull
    private SidbiRole role;
}
