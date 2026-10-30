# IT Infrastructure 통합 작업 계획

[README](README.md) · [회사·네트워크 기준](company-spec.md)

상태: 계획 수립. 체크박스는 실제 실행·증거 확인 후에만 완료한다.
기준: 기존 Network Infrastructure Lab을 변경하지 않고 기존 On-prem AD와 M365를 맞춘다.

## 목표와 작업 원칙

개별 랩에서 익힌 네트워크·계정·클라우드 관리 기능을 같은 회사의 운영 흐름으로 연결한다.
70명 직원 계정과 부서별 대표 테스트 장치를 사용한다. 70대 PC를 구현하는 작업은 아니다.

- 기존 AD를 재사용하고 기존 VM·계정·증거를 보존한다.
- 기존 OU·그룹은 새 구조로 이동하고 검증한 뒤 정리한다.
- 기존 Entra 10명은 먼저 삭제하지 않는다.
- 동기화는 전 직원이 아니라 신규 pilot 1명으로 시작한다.
- 계정/GPO 변경과 IP/DHCP/DNS 변경을 나누어 원인을 추적한다.
- 실제 연결: AD → Entra/M365. PT ↔ VMware: 같은 회사 설계의 별도 구현.
- 상태: 검증됨 / 부분 검증 / 계획 / 미해결. 원인과 가설을 구분한다.
- 비밀번호·토큰·복구 키를 문서·CSV·스크린샷에 공개하지 않는다.
- 실제 시간·성공·실패·건너뜀 건수는 측정 후 기록한다.

## 전체 계획표

아래 시간은 실행 및 증거 정리의 추정치이며 보장 시간이 아니다. VM 대기·제품 요구 사항·provisioning 문제에 따라 달라진다.

| 순서 | 작업 | 예상 작업 시간 | 완료 조건 |
|---|---|---|---|
| 1 | PT 기준 부서·70명 인원·주소 설계 확정, 현황 조사 | 2–3h | 기준표와 현재/목표 대응표 확보 |
| 2 | 기존 AD에 pilot OU·그룹·사용자 1명 준비, AD/DNS 확인 | 1–2h | 도메인 로그인·기본 진단 정상 |
| 3 | Entra 동기화·로그인 우선 검증 | 최초 조사 3h 상한 | 성공 증거 또는 다음 판단을 위한 실패 기록 |
| 4 | 부서 OU·70명·GPO·로그인 제한·파일 권한 확장 | 6–9h | 인원·권한·입사/이동/퇴사 검증 |
| 5 | VMware IP·DHCP·DNS 조정 및 재검증 | 4–7h | 대표 부서 클라이언트의 주소·DNS·인증·relay 경로 확인 |
| 6 | 기존 Entra 10명 매칭 및 M365·Intune 검증 | 3–5h | 기존 계정 유지 여부·동기화 계정의 클라우드 관리 결과 확인 |

합계: 최초 Step 3 조사 포함 약 19–29h. 추가 Connect Sync 구축·비교 조사는 별도 산정한다.
20h 주말에는 모든 단계 완료를 보장하지 않는다. Step 3이 막히면 실제 Hybrid 완료 일정은 보류하고, 독립적으로 가능한 AD 작업을 진행한다.

## Step 1 — 기준 확정과 현황 보존

- [ ] company-spec.md의 원본 부서 인원 확인: HR 8 / ENG 35 / Sales-Marketing 22 / IT 5 = 70
- [ ] PT 최종 VLAN·gateway·DHCP·DNS 표 확인. PT 구성 변경 없음
- [ ] 기존 AD 도메인·DC IP·DNS·DHCP scope·VMnet·라우팅·외부 연결 현황 기록
- [ ] 기존 OU·사용자·그룹·GPO 링크/필터·공유/NTFS 권한 목록 확보
- [ ] 기존 스크립트·CSV·GPO 백업과 VM 복구 지점 확보
- [ ] M365 trial/라이선스 상태와 남은 기간 확인
- [ ] Entra 10명의 UPN·메일 주소/별칭·관리 역할·그룹·라이선스·메일박스·장치 관계 기록
- [ ] 현재 값 / 목표 값 / 변경 시점 / 검증 방법 / 되돌리기 방법 대응표 작성
- [ ] UPN suffix는 AD 도메인과 별도로 검토하고 공식 요구 사항을 확인한 뒤 확정
- [ ] 기존 HR/Finance → HR 표기 대응과 기존 Finance/Operations 사용자 배치 결정

산출물: 확정된 company-spec, 현황 목록, 변경·복구 계획.
현재 company-spec의 PT 값은 문서에서 확인한 기준이며 AD 현장 값은 아직 확인 전이다.

## Step 2 — 기존 AD에서 최소 pilot 준비

- [ ] 기존 도메인 유지. pilot OU와 권한 시험용 그룹 준비
- [ ] 기존 Entra 10명과 UPN/SMTP가 겹치지 않는 일반 pilot 계정 1명 생성
- [ ] pilot을 직원 70명에 포함할지 임시 진단 계정으로 분리할지 기록
- [ ] dcdiag 및 DNS 진단으로 AD/DNS 기본 상태 확인
- [ ] 클라이언트의 AD DNS 사용·도메인 검색·온라인 도메인 로그인 확인
- [ ] 동기화 방식별 지원 OS·권한·통신·시간·UPN 요구 사항 확인
- [ ] 기존 provisioning 구성의 활성 상태와 대상 OU 확인

완료 조건: 기본 AD/DNS가 정상이며 pilot의 속성과 동기화 범위가 명확하다.
이 단계에서 전체 IP 변경이나 기존 부서 삭제를 동시에 수행하지 않는다.

## Step 3 — Entra 동기화·로그인 검증

### 성공 판정

- [ ] pilot OU만 동기화 범위에 포함
- [ ] Entra에 실제 pilot 사용자 생성 확인
- [ ] AD 사용자와 해당 Entra 사용자의 동기화 관계·상태 확인
- [ ] AD 속성 하나를 변경하고 Entra 반영 확인
- [ ] 선택한 인증 방식으로 pilot 클라우드 로그인 별도 검증
- [ ] 오류 코드·시각·로그·사용자 식별 정보의 관계를 비공개 원본에 기록하고 공개용 증거는 정리

에이전트 Active/Healthy 또는 사용자 이름이 보인다는 사실만으로 전체 성공 처리하지 않는다.
사용자 생성 성공과 로그인 성공을 구분한다.

### 같은 오류가 반복될 때

최초 추가 조사는 3h에서 멈추고 결과를 판단한다. 3h는 해결 보장이 아니다.

1. 기존 시도와 현재 로그를 비교한다. 포털 on-demand 결과뿐 아니라 provisioning cycle·에이전트 로그를 함께 확인한다.
2. 새 증거가 가리키는 가설 하나를 검증한다. 이유 없이 AD/테넌트 재구축을 반복하지 않는다.
3. Cloud Sync에서 해결되지 않으면 요구 사항을 확인한 뒤 Connect Sync 비교 시험 범위·시간을 별도로 정한다.
4. 같은 사용자가 두 동기화 도구의 범위에 동시에 포함되지 않도록 기존 구성부터 확인한다.
5. 둘 다 실패하면 재현 절차·로그·오류 시각을 정리하고 지원 경로 또는 환경 분리 시험을 검토한다.

| 결과 | 다음 단계 |
|---|---|
| 사용자 동기화·로그인 성공 | Step 4로 확장 |
| 생성 성공·로그인 실패 | 인증 문제를 분리 조사. Hybrid는 부분 검증 |
| 동기화 실패 | 미해결로 기록. Step 4의 독립 AD 작업은 가능하나 Step 6 Hybrid 검증은 대기 |

수동으로 양쪽에 같은 이름 계정을 생성하는 것은 동기화의 대체가 아니다.

## Step 4 — 부서·70명·운영 정책 확장

- [ ] HR / Engineering / Sales-Marketing / IT OU·그룹 구성
- [ ] 직원 CSV의 부서별 8 / 35 / 22 / 5명과 총원 대조
- [ ] 기존 계정 재사용/이동/신규 생성 명단 구분
- [ ] 기존 스크립트 검토 후 경로·명명·그룹 처리를 수정
- [ ] 입력 검증·중복 확인·WhatIf·로그를 필요한 수준으로 보완
- [ ] 소수 시험 → 전체 실행 → 재실행 중복 및 결과 확인
- [ ] 실행 시간·생성/이동/건너뜀/실패 건수 실측
- [ ] 기존 GPO 백업·대상/필터 확인 후 새 OU에 연결
- [ ] 대표 클라이언트에서 gpresult와 실제 기능 확인
- [ ] HR PC에 HR 계정 허용 / Sales-Marketing 계정 거부 테스트
- [ ] 로그인 제한은 회원 PC 대상 정책으로 검증. 관리자 복구 접근 경로를 유지
- [ ] 로컬 로그인과 RDP 제한은 별도 범위로 기록
- [ ] HR 공유 폴더의 HR 허용 / Sales-Marketing 거부를 별도 검증
- [ ] Joiner: 계정 → OU/그룹 → 로그인 → 파일 접근
- [ ] Mover: 부서·그룹 변경 → 이전 권한 제거 → 새 권한 확인
- [ ] Leaver: 비활성화·그룹 정리·데이터 보관 → 새 인증/접근 차단 확인
- [ ] 캐시 로그인·기존 세션과 새 인증 결과를 구분
- [ ] 검증 후에만 기존 OU·그룹의 남은 의존성을 확인하고 정리

일반 AD 계정의 부서는 IP를 결정하지 않는다. PC의 연결 네트워크가 주소를 결정한다.
모든 부서 OU를 동기화 범위로 자동 확대하지 않고 pilot 범위를 유지한다.

## Step 5 — VMware IP·DHCP·DNS 맞추기

- [ ] host/LAN/VPN과 PT 주소 대역 중복 확인
- [ ] VMnet별 서브넷·라우터·gateway·relay·외부 통신 경로 확정
- [ ] 회사 Data와 Server 세그먼트를 재현할 범위 결정
- [ ] DC/DNS/DHCP의 192.168.1.2 서비스 대응 계획 검토 후 단계적으로 적용
- [ ] gateway 192.168.1.1은 VMware에 실제 라우터가 있을 때만 사용
- [ ] Windows DHCP scope를 PT 최종 임대 범위에 맞춤
- [ ] VMware DHCP와 이중 응답 방지, 고정 주소와 임대 영역 분리
- [ ] 다른 부서 세그먼트에서 중앙 DHCP를 쓸 경우 relay 구성·검증
- [ ] 클라이언트 DNS를 AD DNS로 설정. 외부 해석은 forwarder로 처리
- [ ] 대표 클라이언트의 IP/mask/gateway/DNS·임대·이름 해석 확인
- [ ] 도메인 로그인·GPO·파일 접근 재검증
- [ ] provisioning agent/connector 상태·pilot 속성 변경 반영·클라우드 로그인 재검증

PT의 External-Web 주소는 테스트용이므로 실제 인터넷 경로로 복사하지 않는다.
VMware에서 구현하지 않은 Voice/Guest/Wi-Fi 구간은 PT 검증과 구분한다.

완료 조건: 구현한 VM 세그먼트마다 PT 기준 대응표와 실제 결과가 있다.
전 부서 네트워크를 구현하지 않았다면 대표 부서만 검증했다고 명시한다.

## Step 6 — 기존 Entra 10명과 M365·Intune 연결

- [ ] 기존 10명 중 유지할 직원과 70명 CSV의 대응표 작성
- [ ] 기존 관리자·비상 계정은 일반 직원 pilot과 분리
- [ ] UPN/SMTP·sourceAnchor 관련 속성·이전 동기화 이력·매칭 제한 확인
- [ ] 일반 사용자 1명으로 기존 cloud-only 계정 매칭 시험
- [ ] 새 중복 계정이 생기지 않았는지, 기존 계정의 ID·메일·그룹·라이선스 관계가 유지되는지 확인
- [ ] 매칭 후 변경 관리 위치와 로그인 결과 기록
- [ ] 성공한 방식으로 나머지 대상 사용자만 점진적으로 적용
- [ ] 기존 10명 일괄 삭제·재생성은 하지 않음
- [ ] 동기화된 pilot 계정에 필요한 라이선스를 확인하고 메일·그룹 접근 시험
- [ ] 동기화된 pilot 계정과 테스트 장치로 Intune 등록/사용 흐름 검증
- [ ] 앱 배포·compliance·BitLocker 결과 확인
- [ ] CA는 비상 관리자 제외·테스트 그룹 범위 확인 후 평가/차단/복구를 각각 기록
- [ ] compliance 정책 조건·유예·체크인·새 로그인 평가와 대기 시간을 고려
- [ ] 클라우드 Leaver 시험 시 로그인 차단·세션 회수 → 메일/데이터 보관 → 라이선스 회수 → 검증 순서로 계획

AD 사용자 동기화, Windows 장치 Entra join, Intune 등록은 별개의 검증이다.
이번 계획에서 Hybrid device join을 완료했다고 자동으로 주장하지 않는다.

## 문서·증거 관리

- 통합 저장소: 회사 기준, 전체 계획, 연결 관계와 상태.
- homelab: 실제 AD 스크립트·CSV·구축 방법·장애 기록·증거.
- M365 저장소: 동기화·계정 매칭·메일·Intune·CA 결과.
- Network 저장소: 기존 PT 구현과 증거 유지. 이번 작업을 위해 변경하지 않음.
- AD 문서는 README / HowTo / ProblemSolving으로 분리하고 기존 링크와 증거를 보존.
- 각 Step 종료 시 결과 링크·상태·실제 시간·다음 작업을 갱신.
- 공개 전 비밀 정보·깨진 링크·검증되지 않은 완료 표현을 확인.

## 최종 완료 기준

- [ ] PT 기준의 부서·70명·주소 설계 대응 확정
- [ ] AD 직원 계정·그룹·GPO·로그인 제한·파일 권한 검증
- [ ] VMware에서 실제 구현한 IP/DHCP/DNS 범위 검증
- [ ] AD pilot → Entra 실제 동기화 및 로그인 검증
- [ ] 기존 Entra 계정의 매칭 결과·보존 상태 확인
- [ ] 동기화된 계정으로 M365·Intune 관리 흐름 검증
- [ ] PT와 VMware의 설계 대응 및 실제 Hybrid 연동을 구분해 문서화

동기화가 실패해도 독립 AD 작업은 계속할 수 있다. 다만 실제 Hybrid 통합 완료 조건은 충족하지 않은 것으로 남긴다.

## 구현 전 확인할 공식 자료

- [Cloud Sync troubleshooting](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-troubleshoot)
- [Synchronization tools](https://learn.microsoft.com/en-us/entra/identity/hybrid/sync-tools)
- [Existing tenant matching](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-existing-tenant)
- [Cloud Sync supported topologies](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/plan-cloud-sync-topologies)
