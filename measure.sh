#!/usr/bin/env bash
# 读数：页面加载次数（可靠）+ 进来的人/点了的人（计数服务活着时）+ 付款笔数（最硬，看账单）
# 用法：bash measure.sh [YYYYMMDD]，默认今天
set -uo pipefail
NS=gongwei-muyu-live
D="${1:-$(date +%Y%m%d)}"

abacus_get() {
  local v
  v=$(curl -s -m 8 "https://abacus.jasoncameron.dev/get/$NS/$1" 2>/dev/null \
      | python3 -c 'import sys,json
try: print(json.load(sys.stdin)["value"])
except Exception: print("-")' 2>/dev/null)
  [ -z "$v" ] && v="-"
  printf '%s' "$v"
}

PV=$(curl -s -m 8 "https://hits.sh/gongwei-muyu.app/pv.svg" 2>/dev/null \
     | grep -o 'hits: [0-9]*' | head -1 | grep -o '[0-9]*')
[ -z "$PV" ] && PV="读取失败"

UV=$(abacus_get "uv-$D")
TAP=$(abacus_get "tap-$D")

echo "日期        : $D"
echo "页面加载数  : $PV   ← 最可靠的数（含我测试时的 3 次）"
echo "进来的人    : $UV   ← 计数服务活着时才有"
echo "点了的人    : $TAP"
if [ "$UV" != "-" ] && [ "$TAP" != "-" ] && [ "$UV" -gt 0 ] 2>/dev/null; then
  python3 -c "print('点下去比例  : %.0f%%' % ($TAP/$UV*100))"
fi
echo "付款笔数    : 看微信/支付宝账单里的 1 元入账 —— 这个数决定实验结论"
