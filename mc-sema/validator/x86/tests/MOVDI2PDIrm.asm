BITS 32
;TEST_FILE_META_BEGIN
;TEST_TYPE=TEST_F
;TEST_IGNOREFLAGS=
;TEST_FILE_META_END

mov eax, 2

;TEST_BEGIN_RECORDING
lea ecx, [esp-4]
mov [ecx], eax
movd xmm0, [ecx]
mov ecx, 0
;TEST_END_RECORDING

cvtsi2sd xmm0, ecx
