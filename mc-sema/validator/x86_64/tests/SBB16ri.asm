BITS 64
;TEST_FILE_META_BEGIN
;TEST_TYPE=TEST_F
;TEST_IGNOREFLAGS=
;TEST_FILE_META_END
    ; SBB16ri
    mov bx, 0x7
    ;TEST_BEGIN_RECORDING
    sbb bx, 0x444
    ;TEST_END_RECORDING
