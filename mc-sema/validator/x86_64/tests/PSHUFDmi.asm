BITS 64
;TEST_FILE_META_BEGIN
;TEST_TYPE=TEST_F
;TEST_IGNOREFLAGS=FLAG_SF|FLAG_PF
;TEST_FILE_META_END

;TEST_BEGIN_RECORDING
lea rcx, [rsp-0x30]
and rcx, 0xFFFFFFFFFFFFFFF0

mov dword [rcx+0x00], 0xAAAAAAAA
mov dword [rcx+0x04], 0xBBBBBBBB
mov dword [rcx+0x08], 0xCCCCCCCC
mov dword [rcx+0x0C], 0xDDDDDDDD

pshufd xmm0, [rcx], 0x4E
mov ecx, 0
;TEST_END_RECORDING

cvtsi2sd xmm0, ecx

