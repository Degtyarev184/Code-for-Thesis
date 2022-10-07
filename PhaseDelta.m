function y = PhaseDelta(m1,m2)
    y = atan((sin(m1) + sin(m2))/(cos(m1) + cos(m2)));
end