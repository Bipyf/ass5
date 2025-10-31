
import os
from typing import List

def compute_total(expenses: List[float]) -> float:
    return round(sum(expenses), 2)

def load_expenses_from_env() -> List[float]:
    raw = os.getenv("EXPENSES", "")
    if not raw.strip():
        # default "research" sample
        return [120.0, 89.9, 15.6, 125.0]
    return [float(x) for x in raw.split(",") if x.strip()]

if __name__ == "__main__":
    expenses = load_expenses_from_env()
    total = compute_total(expenses)
    print(f"TOTAL_EXPENSES={total}")
