function Ps = PsState(X)

if inFOV(X)
    Ps = 0.99;
else
    Ps = 0.2;
end