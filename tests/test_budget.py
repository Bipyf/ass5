
from budget_analyzer import compute_total

def test_compute_total_rounding():
    assert compute_total([0.1, 0.2, 0.3]) == 0.6

def test_compute_total_typical():
    assert compute_total([120.0, 89.9, 15.6, 125.0]) == 350.5
