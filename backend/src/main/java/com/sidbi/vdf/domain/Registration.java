package com.sidbi.vdf.domain;

import com.sidbi.vdf.domain.enums.MsmeStatus;
import com.sidbi.vdf.domain.enums.RegistrationStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "VDF_registration")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Registration {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String email;

    @Column(name = "name_of_applicant", nullable = false)
    private String nameOfApplicant;

    @Column(name = "registered_office")
    private String registeredOffice;

    @Column(name = "location_of_facilities")
    private String locationOfFacilities;

    @Column(name = "date_of_incorporation")
    private String dateOfIncorporation;

    @Column(name = "date_of_commencement")
    private String dateOfCommencement;

    @Column(name = "pan_no")
    private String panNo;

    @Column(name = "gst_no")
    private String gstNo;

    @Column(name = "cin", length = 21)
    private String cin;

    @Enumerated(EnumType.STRING)
    @Column(name = "msme_status")
    private MsmeStatus msmeStatus;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private RegistrationStatus status = RegistrationStatus.pending;

    @Column(name = "submitted_at", nullable = false)
    private Instant submittedAt;

    /** Populated at query time from UserAccount.enabled — not persisted. */
    @Transient
    private Boolean enabled;
}
