package com.sidbi.vdf.domain.enums;

public enum AppStatus {
    submitted,
    pending_review,
    under_review,  // UI alias when meeting scheduled (icvd/ccic)
    reverted,
    approved,
    rejected,
    recommended_for_approval,
    recommended_for_rejection,
    recommend_pursual,
    recommend_rejection,
    sanctioned
}
