"""
배송 지연 여부와 재구매 여부가 통계적으로 유의미하게 연관되어 있는지 검정.

귀무가설(H0): 배송 지연 여부와 재구매 여부는 서로 무관하다(독립이다)
대립가설(H1): 배송 지연 여부와 재구매 여부는 서로 관련이 있다
"""
from scipy.stats import chi2_contingency

# 03_delivery_delay_repurchase.sql 쿼리 결과 (BigQuery에서 그대로 가져온 값)
#            재구매   단발성
# 지연        429      7397
# 정시       5670     82974
table = [
    [429, 7397],
    [5670, 82974],
]

chi2, p, dof, expected = chi2_contingency(table)

print(f"chi2 = {chi2:.3f}")
print(f"p-value = {p:.5f}")
print(f"자유도 = {dof}")
print("기대값(두 변수가 무관하다고 가정했을 때의 값):")
print(expected)

if p < 0.05:
    print("\n=> p < 0.05: 귀무가설 기각. 배송 지연과 재구매는 통계적으로 유의미하게 연관되어 있다.")
else:
    print("\n=> p >= 0.05: 귀무가설 기각 불가. 우연한 차이일 가능성을 배제할 수 없다.")
