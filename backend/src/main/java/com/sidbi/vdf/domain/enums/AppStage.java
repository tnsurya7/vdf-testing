package com.sidbi.vdf.domain.enums;

import com.fasterxml.jackson.annotation.JsonValue;

public enum AppStage {
    prelim,
    detailed,
    icvd,
    ccic,
    final_("final"),
    post_sanction;

    private final String value;

    AppStage() {
        this.value = name();
    }

    AppStage(String value) {
        this.value = value;
    }

    @JsonValue
    public String getValue() {
        return value;
    }
}
