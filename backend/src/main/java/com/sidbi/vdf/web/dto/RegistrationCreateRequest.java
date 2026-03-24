package com.sidbi.vdf.web.dto;

import com.sidbi.vdf.domain.enums.MsmeStatus;
import lombok.Data;

import java.time.Instant;

/**
 * Request body for creating a registration. Includes password so a user_account
 * can be created and the user can log in with the same credentials.
 */
@Data
public class RegistrationCreateRequest {
    private String email;
    private String password;
    private String nameOfApplicant;
    private String registeredOffice;
    private String locationOfFacilities;
    private String dateOfIncorporation;
    private String dateOfCommencement;
    private String panNo;
    private String gstNo;
    private String cin;
    private MsmeStatus msmeStatus;
}
