package com.sidbi.vdf.domain;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommitteeMember implements Serializable {
    private String id;
    private String name;
    private String email;
}
