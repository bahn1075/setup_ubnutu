#!/bin/bash
# setup-oke-kubeconfig-fixed.sh

set -e

echo "=== OKE Cluster를 kubectl context로 등록 ==="

# Tenancy OCID 가져오기
TENANCY_OCID=$(grep tenancy ~/.oci/config | cut -d'=' -f2 | tr -d ' ')
echo "Tenancy OCID: $TENANCY_OCID"

# Region 가져오기
REGION=$(grep region ~/.oci/config | head -1 | cut -d'=' -f2 | tr -d ' ')
echo "Region: $REGION"

# 먼저 모든 Compartment 조회
echo -e "\n=== Compartment 조회 중... ==="
COMPARTMENTS=$(oci iam compartment list --all --query 'data[*].id' --raw-output)

# Root Compartment(Tenancy)도 포함
ALL_COMPARTMENTS="$TENANCY_OCID $COMPARTMENTS"

echo -e "\n=== 클러스터 조회 중... ==="
CLUSTER_ID=""
CLUSTER_NAME=""

# 각 Compartment에서 클러스터 검색
for COMP_ID in $ALL_COMPARTMENTS; do
  RESULT=$(oci ce cluster list \
    --compartment-id "$COMP_ID" \
    --lifecycle-state ACTIVE \
    --query 'data[0]' \
    --raw-output 2>/dev/null || echo "")
  
  if [ -n "$RESULT" ] && [ "$RESULT" != "null" ] && [ "$RESULT" != "[]" ]; then
    CLUSTER_ID=$(echo "$RESULT" | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
    CLUSTER_NAME=$(echo "$RESULT" | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$CLUSTER_ID" ]; then
      echo "✓ 클러스터 발견!"
      break
    fi
  fi
done

if [ -z "$CLUSTER_ID" ]; then
  echo "❌ ACTIVE 상태의 클러스터를 찾을 수 없습니다."
  echo -e "\n모든 상태의 클러스터 확인:"
  for COMP_ID in $ALL_COMPARTMENTS; do
    oci ce cluster list --compartment-id "$COMP_ID" --all 2>/dev/null || true
  done
  exit 1
fi

echo -e "\n=== 클러스터 정보 ==="
echo "Name: $CLUSTER_NAME"
echo "ID: $CLUSTER_ID"
echo "Region: $REGION"

# 환경 변수 설정
export OKE_CLUSTER_ID=$CLUSTER_ID
export OKE_CLUSTER_NAME=$CLUSTER_NAME
export OKE_REGION=$REGION

# kubeconfig 디렉토리 생성
mkdir -p ~/.kube

# 기존 kubeconfig 백업 (있는 경우)
if [ -f ~/.kube/config ]; then
  echo -e "\n기존 kubeconfig 백업 중..."
  cp ~/.kube/config ~/.kube/config.backup.$(date +%Y%m%d_%H%M%S)
fi

# kubeconfig 생성
echo -e "\n=== Kubeconfig 생성 중... ==="
oci ce cluster create-kubeconfig \
  --cluster-id $OKE_CLUSTER_ID \
  --file ~/.kube/config \
  --region $OKE_REGION \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT \
  --overwrite

echo -e "\n✅ Kubeconfig 생성 완료!"

# 연결 테스트
echo -e "\n=== 클러스터 연결 테스트 ==="
kubectl cluster-info
echo ""
kubectl get nodes

echo -e "\n=== 환경 변수 ==="
echo "export OKE_CLUSTER_ID=$OKE_CLUSTER_ID"
echo "export OKE_CLUSTER_NAME=$OKE_CLUSTER_NAME"
echo "export OKE_REGION=$OKE_REGION"

echo -e "\n✅ 설정 완료!"