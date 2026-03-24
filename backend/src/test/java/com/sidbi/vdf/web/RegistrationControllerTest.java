package com.sidbi.vdf.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sidbi.vdf.domain.enums.MsmeStatus;
import com.sidbi.vdf.web.dto.RegistrationCreateRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class RegistrationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void create_withValidRequest_returns200AndRegistration() throws Exception {
        RegistrationCreateRequest request = new RegistrationCreateRequest();
        request.setEmail("newapplicant@example.com");
        request.setPassword("secret");
        request.setNameOfApplicant("Test Co");
        request.setMsmeStatus(MsmeStatus.micro);

        mockMvc.perform(post("/api/registrations")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value("newapplicant@example.com"))
            .andExpect(jsonPath("$.status").value("pending"));
    }
}
