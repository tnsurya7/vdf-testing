package com.sidbi.vdf.domain.enums;

public enum SidbiRole {
    admin,
    maker,
    checker,
    convenor,
    committee_member,          // legacy – kept for backward compat
    icvd_committee_member,
    ccic_committee_member,
    approving_authority        // legacy – kept for backward compat; use checker/convenor for new users
}
