# IT Infrastructure Portfolio

Network, On-prem Active Directory, M365 랩을 같은 70명 회사의 설계와 직원 관리 흐름으로 연결하는 프로젝트.

현재 상태: **통합 계획 수립. AD 재정렬·Hybrid 연동·최종 VMware 주소 변경은 검증 전이다.**
기존 개별 랩의 결과는 각 저장소에서 확인한다.

## 문서

- **[통합 작업 계획](integration-plan.md)** — 합의한 6단계 작업, 체크리스트, 완료 조건, provisioning 실패 시 대책
- **[회사·네트워크 기준](company-spec.md)** — Packet Tracer의 실제 부서 인원, VLAN, IP, DHCP, DNS 기준

## 기존 프로젝트

| Layer | 저장소 | 이번 통합에서의 역할 |
|---|---|---|
| Network | [Network Infrastructure Lab](https://github.com/junuiui/network-infrastructure-lab) | 변경하지 않는 회사 네트워크 기준 |
| On-prem identity | [AD Homelab](https://github.com/junuiui/homelab) | 기존 AD를 재사용해 부서·70명·권한·정책 정렬 |
| Cloud identity / endpoint | [M365, Entra & Intune Lab](https://github.com/junuiui/m365-entra-intune-lab) | pilot 동기화·기존 계정 매칭·클라우드 및 장치 관리 검증 |

## 진행 순서

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | PT 기준 부서·70명·주소 기준 정리 및 현재 AD와 대조 | PT 문서 기준 추출 완료 / 실제 환경 대조 예정 |
| 2 | 기존 AD에 pilot OU·그룹·사용자 1명 준비, AD/DNS 확인 | 계획 |
| 3 | Entra 동기화·로그인 우선 검증 | 계획 / 기존 Cloud Sync 시도는 미해결 |
| 4 | 부서별 OU·70명·GPO·로그인 제한·파일 권한 확장 | 계획 |
| 5 | VMware IP·DHCP·DNS 조정 및 재검증 | 계획 |
| 6 | 기존 Entra 10명 매칭 및 M365·Intune 검증 | 계획 |

직원 기준: **HR 8 / Engineering 35 / Sales-Marketing 22 / IT 5 = 70**.
원래 회사 설계의 HR/Finance를 현재 Network의 HR 표기에 대응시킨다.

## 연결 범위

- Packet Tracer ↔ VMware: 같은 부서·주소·서비스 설계를 사용하는 별도 구현. 직접 통신하는 환경이라고 표현하지 않는다.
- On-prem AD → Entra/M365: 실제 사용자 동기화와 로그인을 확인해야 완료.
- Entra/M365 → Intune: 동기화된 pilot 계정과 테스트 장치로 관리 흐름을 별도 검증.
- 70명은 직원 계정 수다. 대표 장비와 소수의 테스트 VM으로 기능을 검증한다.
- 기존 Entra 10명은 삭제하지 않고 사용 내역 조사 후 단계적으로 매칭한다.

## 작업 기록 원칙

완료된 결과만 검증됨으로 표시한다. 계획·부분 검증·미해결은 별도로 남긴다.
구축 절차·스크립트·증거는 각 원래 저장소에서 관리하고 이 저장소는 공통 기준과 연결 관계를 관리한다.
