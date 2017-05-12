function clamped = clamp(x, lower, upper)

clamped = min(max(x, lower), upper);
