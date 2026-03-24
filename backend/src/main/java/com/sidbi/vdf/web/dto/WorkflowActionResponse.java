package com.sidbi.vdf.web.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WorkflowActionResponse {
    private boolean success;
    private String error;
}
