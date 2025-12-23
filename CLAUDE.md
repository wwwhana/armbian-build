# 🎯 X98K 블루투스 (AIC8800) 포팅 현황 요약

## 1. 개요
- **칩셋:** AIC8800 (SDIO WiFi / UART Bluetooth)
- **UART:** `/dev/ttyS2`
- **핵심 목표:** 안드로이드와 동일한 GPIO 제어 시퀀스를 구현하여 블루투스 칩을 활성화하고 `hci0`를 올리는 것.

## 2. 진단 및 분석
- **RTS 핀 충돌:** 안드로이드에서는 RTS(GPIO1_B2)를 UART 기능이 아닌 GPIO로 직접 제어함. 기존 Armbian DTS에서는 UART2가 이를 점유하고 있어 칩 초기화가 불가능했음.
- **초기화 시퀀스 부재:** 부팅 시 RESET(GPIO1_C1) 펄스와 WAKE(GPIO1_B4) 핀 제어가 필수적임.

## 4. 다음 단계
- [ ] 원인 분석
- [ ] 설정 수정
- [ ] SCP를 통한 DTB  전송
- [ ] 보드 재부팅 및 `hci0` 생성 확인
- [ ] `hciconfig -a` 및 `dmesg` 로그 등을 분석을 통한 최종 검증

# 필요 명령어
 - ./compile.sh kernel-dtb BOARD=x98k BRANCH=vendor BUILD_DESKTOP=no BUILD_MINIMAL=no KERNEL_CONFIGURE=no RELEASE=noble  
   - 빌드 후 로그파일에 나온 deb를 scp로 보드에 전송후 설치할 것
 - ssh armbian 
   - ssh를 통해 장비에 접근 할 수 있음
 - adb shell
   - adb를 통해서 안드로이드 장비에서 동작을 확인 가능

# 참고사항
 gemini가 기능을 일부 포팅시도하면서 잘못된 결과를 도출 했을 수도 있습니다.
 dtb와 uart 설정과 펌웨어 로딩외에는 검수할 것이 없습니다. 그 외사항은 선택지에 넣지 마시오.
 필요시 안드로이드 dtb를 추출하여 참고 가능합니다.