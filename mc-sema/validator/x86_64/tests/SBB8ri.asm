BITS 64
;TEST_FILE_META_BEGIN
;TEST_TYPE=TEST_F
;TEST_IGNOREFLAGS=
;TEST_FILE_META_END
    ; SBB8ri
    mov ah, 0x99
    ;TEST_BEGIN_RECORDING
    sbb ah, 0x3
    ;TEST_END_RECORDING

