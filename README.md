# IT Infrastructure Portfolio

Network, On-prem Active Directory, M365 랩을 같은 70명 회사의 설계와 직원 관리 흐름으로 연결하는 프로젝트.

현재 상태: **Connect Sync로 AD 직원 70명 동기화. Emma 1명의 클라우드 로그인·속성 변경 검증 완료.**
부서 그룹·GPO·파일 권한 및 새 계정 기반 M365·Intune 검증은 다음 작업이다. 상세 증거 범위는 진행 기록에서 구분한다.
기존 개별 랩의 결과는 각 저장소에서 확인한다.

## 문서

- **[2026-10-30 진행 기록](progress-2026-10-30.md)** — 네트워크·DNS 정리, Cloud Sync 조사, Connect Sync 70명 확장 및 검증 한계

- **[통합 작업 계획](integration-plan.md)** — 합의한 6단계 작업, 체크리스트, 완료 조건, provisioning 실패 시 대책
- **[회사·네트워크 기준](company-spec.md)** — Packet Tracer의 실제 부서 인원, VLAN, IP, DHCP, DNS 기준

## 기존 프로젝트

| Layer | 저장소 | 이번 통합에서의 역할 |
|---|---|---|
| Network | [Network Infrastructure Lab](https://github.com/junuiui/network-infrastructure-lab) | 변경하지 않는 회사 네트워크 기준 |
| On-prem identity | [AD Homelab](https://github.com/junuiui/homelab) | 기존 Homelab 보존, 별도 jh.test AD에 70명 구성. 권한·정책은 다음 단계 |
| Cloud identity / endpoint | [M365, Entra & Intune Lab](https://github.com/junuiui/m365-entra-intune-lab) | Connect Sync 계정 동기화 완료. 클라우드 앱·장치 검증은 예정 |

## 진행 순서

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | PT 기준 부서·70명·주소 설계 | 부서·인원·서버망 주소 반영 |
| 2 | jh.test AD 사용자·pilot·DNS 준비 | 70명 생성·DNS 수정. 그룹은 예정 |
| 3 | Entra 동기화·로그인 검증 | Connect Sync 성공: Emma 로그인·속성 반영 / Cloud Sync 미해결 |
| 4 | 직원 70명 확장 및 부서 운영 정책 | 전체 계정 동기화 완료 보고 / 그룹·GPO·권한 예정 |
| 5 | VMware IP·DHCP·DNS | 서버망·라우터·DNS 검증 / 부서별 DHCP·relay 미검증 |
| 6 | AD 직원 기준으로 M365·Intune 검증 | 기존 cloud-only 직원 10명 삭제. 새 직원 기반 검증 예정 |

직원 기준: **HR 8 / Engineering 35 / Sales-Marketing 22 / IT 5 = 70**.
원래 회사 설계의 HR/Finance를 현재 Network의 HR 표기에 대응시킨다.

## 연결 범위

- Packet Tracer ↔ VMware: 같은 부서·주소·서비스 설계를 사용하는 별도 구현. 직접 통신하는 환경이라고 표현하지 않는다.
- On-prem AD → Entra/M365: 실제 사용자 동기화와 로그인을 확인해야 완료.
- Entra/M365 → Intune: 동기화된 pilot 계정과 테스트 장치로 관리 흐름을 별도 검증.
- 70명은 직원 계정 수다. 대표 장비와 소수의 테스트 VM으로 기능을 검증한다.
- 사용자 결정으로 기존 cloud-only 직원 10명을 삭제하고 AD 70명으로 통일했다. 관리자와 Sales 계정은 유지했다.
- 현재 72개 활성 사용자 객체: 직원 70명 + 관리자 1명 + Sales 1개. 70명 전체의 로그인·라이선스 할당을 검증한 것은 아니다.

## 작업 기록 원칙

완료된 결과만 검증됨으로 표시한다. 계획·부분 검증·미해결은 별도로 남긴다.
구축 절차·스크립트·증거는 각 원래 저장소에서 관리하고 이 저장소는 공통 기준과 연결 관계를 관리한다.
