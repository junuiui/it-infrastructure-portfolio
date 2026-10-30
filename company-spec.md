# Company Spec — Network Lab 기준

[README](README.md) · [통합 작업 계획](integration-plan.md)

## 문서 상태와 기준

이 문서는 기존 Packet Tracer 환경을 변경하지 않고 AD와 M365를 맞추기 위한 기준이다. 아래 네트워크 값은 저장소 문서에서 확인했으며, VMware 구현 완료를 뜻하지 않는다.

- 최종 주소·DHCP 기준: [Network HowTo](https://github.com/junuiui/network-infrastructure-lab/blob/main/HowTo.md)
- 인원 기준: [기존 회사 설계](https://github.com/junuiui/network-infrastructure-lab/blob/69d8c1a8993dfd07d1f167922214b5a84aa0ceb9/docs/architecture.md)
- 과거 주소가 아닌 HowTo의 최종 주소를 따른다.
- Packet Tracer 파일과 Network 저장소는 이번 문서 작업에서 변경하지 않는다.

## 직원과 장치

| 공통 부서 | 원본 회사 설계 | Network 표기 | 직원 계정 목표 |
|---|---|---|---:|
| HR | HR/Finance | HR | 8 |
| Engineering | Engineering | ENG | 35 |
| Sales-Marketing | Sales/Marketing | S/M, SM | 22 |
| IT | IT | IT | 5 |
| 합계 | | | 70 |

HR은 원래 HR/Finance 8명 조직의 네트워크 표기를 따른다. Finance를 별도 다섯 번째 부서로 추가하지 않는다. 기존 cloud-only 직원 10명은 삭제하고 AD 직원 70명으로 통일했다. 기존 관리자와 Sales 계정은 유지한다.

70명은 직원 계정 수다. 부서별 대표 PC·전화기·프린터와 소수의 VMware 클라이언트로 기능을 검증한다. 70대 동시 접속이나 부하 검증은 범위에 포함하지 않는다. 직원은 AD 기준 70명이며, 관리자 1명과 Sales 계정 객체 1개를 포함한 Entra 활성 사용자 수는 72개로 확인했다. 별도 진단 계정·관리자·서비스 계정은 직원 수와 분리한다.

## 최종 VLAN·서브넷·게이트웨이

| Network | VLAN | Subnet | Gateway |
|---|---:|---|---|
| HR Data | 10 | 192.168.0.192/27 | 192.168.0.193 |
| HR Voice | 110 | 192.168.0.224/27 | 192.168.0.225 |
| ENG Data | 20 | 192.168.0.0/26 | 192.168.0.1 |
| ENG Voice | 120 | 192.168.0.64/26 | 192.168.0.65 |
| S/M Data | 30 | 192.168.1.64/26 | 192.168.1.65 |
| S/M Voice | 130 | 192.168.1.128/26 | 192.168.1.129 |
| IT Data | 40 | 192.168.1.16/28 | 192.168.1.17 |
| IT Voice | 140 | 192.168.1.32/28 | 192.168.1.33 |
| Server | 50 | 192.168.1.0/28 | 192.168.1.1 |
| Guest | 99 | 192.168.1.192/26 | 192.168.1.193 |
| Staff Wi-Fi | 60 | 192.168.2.0/25 | 192.168.2.1 |

## 최종 DHCP 기준

| Pool | Lease range | Mask | Gateway |
|---|---|---|---|
| HR-Data | 192.168.0.194–192.168.0.219 | 255.255.255.224 | 192.168.0.193 |
| ENG-Data | 192.168.0.2–192.168.0.59 | 255.255.255.192 | 192.168.0.1 |
| S/M-Data | 192.168.1.66–192.168.1.125 | 255.255.255.192 | 192.168.1.65 |
| IT-Data | 192.168.1.18–192.168.1.27 | 255.255.255.240 | 192.168.1.17 |
| HR-Voice | 192.168.0.226–192.168.0.254 | 255.255.255.224 | 192.168.0.225 |
| ENG-Voice | 192.168.0.66–192.168.0.125 | 255.255.255.192 | 192.168.0.65 |
| S/M-Voice | 192.168.1.130–192.168.1.190 | 255.255.255.192 | 192.168.1.129 |
| IT-Voice | 192.168.1.34–192.168.1.46 | 255.255.255.240 | 192.168.1.33 |
| Guests | 192.168.1.194–192.168.1.254 | 255.255.255.192 | 192.168.1.193 |
| Staff-WiFi | 192.168.2.10–192.168.2.119 | 255.255.255.128 | 192.168.2.1 |
| serverPool | 192.168.1.6 only | 255.255.255.240 | 192.168.1.1 |

- Staff/Data DNS: 192.168.1.2.
- Guest DNS: 203.0.113.10 (PT external test server).
- Voice DNS: 0.0.0.0; TFTP: 192.168.1.4.
- serverPool: PT 기본 pool의 단일 임대 workaround. VMware Windows DHCP에 불필요하게 재현하지 않는다.
- DHCP pool 최대 임대 수는 직원 수가 아니다.

## 고정 주소와 DNS 서비스 대응

| 대상 | Packet Tracer 기준 | VMware 목표/판단 |
|---|---|---|
| DHCP/DNS | 192.168.1.2/28 | Windows Server DHCP/DNS 서비스 대응 주소 목표. 기존 DC 주소 변경 전 의존성·충돌 확인 |
| Web | 192.168.1.3/28 | 기존 PT 역할 유지. VM에 실제 웹 서버를 구현하는 것은 별도 작업 |
| Voice/CME | 192.168.1.4/28 | PT에서 검증. AD 랩에서 전화 기능 재구축하지 않음 |
| Server gateway | 192.168.1.1 | VMware에 실제 라우터 경로를 구성한 후 사용 |
| HR printer | 192.168.0.221/27 | DHCP에서 제외 |
| ENG printer | 192.168.0.62/26 | DHCP에서 제외 |
| S/M printer | 192.168.1.126/26 | DHCP에서 제외 |
| IT printer | 192.168.1.30/28 | DHCP에서 제외 |
| HR switch management | 192.168.0.220/27 | 고정 주소 예약 영역 |
| IT switch management | 192.168.1.28/28 | 고정 주소 예약 영역 |

PT 내부 A record는 intranet.fakecompany.test → 192.168.1.3이다. PT 외부 테스트 서버 203.0.113.10은 실제 인터넷 DNS나 VMware 외부 통신 경로로 사용하지 않는다.

Windows AD DNS에는 도메인 검색·인증용 레코드가 필요하다. PT의 일반 DNS A record만 복사하는 것으로 AD DNS 구성을 완료했다고 판단하지 않는다. 도메인 클라이언트는 AD DNS를 사용하고, 외부 이름 해석은 DNS forwarder로 처리할 계획이다.

## VMware 구현 범위와 사전 결정

- 기존 Homelab AD는 보존하고, 별도 실험용으로 구성했던 jh.test AD를 통합 환경으로 사용한다.
- AD domain: jh.test. DC: WIN-9TRC5DR3JHV. 직원 UPN suffix: junuihonglab.onmicrosoft.com.
- 계정 명명: 소문자 firstnamelastname, 구분자·prefix 없음. 동명 충돌은 별도 확인 후 처리한다.
- 장치 명명 초안: HR-PC-01 / ENG-PC-01 / SM-PC-01 / IT-PC-01.
- 부서별 네트워크를 재현하려면 분리된 가상 세그먼트, 각 gateway, 라우팅과 DHCP relay 경로를 구성해야 한다.
- VMnet 번호는 현재 VMware 구성을 조사한 뒤 정한다. VMnet 분리를 802.1Q VLAN 구현으로 표현하지 않는다.
- Voice·Guest·Wi-Fi는 PT의 기준을 유지하되 VMware에서 실제 구현한 범위만 검증 완료로 기록한다.
- VMware 자체 DHCP와 Windows DHCP가 같은 세그먼트에서 충돌하지 않도록 확인한다.
- 호스트/LAN/VPN과 주소 중복을 먼저 확인한다. 중복 시 PT를 변경하지 않고 VMware 격리·라우팅 방식을 결정한다.
- pilot 단계는 현재 정상 동작하는 네트워크에서 수행한다. Step 5에서 최종 주소로 변경한 뒤 동기화를 다시 검증한다.

## 연결의 의미

PT ↔ VMware는 공통 설계 대응이다. 두 환경이 실제 연결되어 있다고 주장하지 않는다.
AD → Entra는 실제 동기화와 로그인을 확인해야 완료다.
Entra/M365 → Intune은 동기화된 pilot 계정과 테스트 장치로 별도 확인해야 완료다.

## 현재 구현 상태 — 2026-10-30

- DC는 VMnet3 192.168.1.2/28, gateway 192.168.1.1, DNS 192.168.1.2.
- Ubuntu router: ens34/VMnet3 192.168.1.1/28, ens33/VMnet8 10.0.0.10/24, 외부 gateway 10.0.0.2.
- VMnet8 NAT망 10.0.0.0/24 유지. VMnet3의 host adapter와 VMware DHCP 비활성.
- 실제 LAN 192.168.1.0/24와 주소가 겹쳐 별도 내부 세그먼트로 분리. Ubuntu forwarding·MASQUERADE 및 DC outbound TCP 443 확인.
- AD DNS forwarders: 1.1.1.1 / 8.8.8.8. DNS test passed 보고.
- Connect Sync로 직원 70명 동기화·예약 동기화 설정 완료 보고. Emma 1명 로그인·Title 변경 반영 검증.
- Cloud Sync는 Disabled, 근본 원인 미해결. 기존 cloud-only 직원 10명은 매칭 대신 삭제했다.
- DHCP 역할·부서별 scope·relay와 전체 부서 VM 네트워크는 아직 검증하지 않았다. 위 표의 목표를 전부 구현했다고 해석하지 않는다.
- [상세 진행 기록과 증거 범위](progress-2026-10-30.md)
