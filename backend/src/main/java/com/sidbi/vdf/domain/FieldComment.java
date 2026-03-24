package com.sidbi.vdf.domain;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FieldComment implements Serializable {
    private boolean needsChange;
    private String comment;
}
