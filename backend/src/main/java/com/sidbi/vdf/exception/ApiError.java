package com.sidbi.vdf.exception;

import lombok.Data;

@Data
public class ApiError {
    private String error;
    private String code;
    private String message;

    public ApiError() {}

    public ApiError(String error, String code, String message) {
        this.error = error;
        this.code = code;
        this.message = message;
    }

    public static ApiErrorBuilder builder() {
        return new ApiErrorBuilder();
    }

    public static final class ApiErrorBuilder {
        private String error;
        private String code;
        private String message;

        ApiErrorBuilder() {}

        public ApiErrorBuilder error(String error) {
            this.error = error;
            return this;
        }

        public ApiErrorBuilder code(String code) {
            this.code = code;
            return this;
        }

        public ApiErrorBuilder message(String message) {
            this.message = message;
            return this;
        }

        public ApiError build() {
            return new ApiError(error, code, message);
        }
    }
}
