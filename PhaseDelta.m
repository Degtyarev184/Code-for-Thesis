function y = PhaseDelta(m1,m2)
    y = atan((cos(m1) + cos(m2))/(sin(m1) + sin(m2)));
end