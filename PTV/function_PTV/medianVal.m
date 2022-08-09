function [U,V,Info]=medianVal(U,V,ValPar)
ker=ValPar.ker;
[S1,S2]=size(U);
Info=ones(size(U));

for i=1:S1
    for j=1:S2
        dumU=U(max([1,i-ker]):min([S1,i+ker]),max([1,j-ker]):min([S2,j+ker]));
        mU=median(dumU(:));
        rm=median(abs(dumU(:)-mU));
        err=abs(U(i,j)-mU)/(rm+ValPar.eps);
        if err>ValPar.UnivTh
            Info(i,j)=0;
            U(i,j)=mU;
        end
        dumV=V(max([1,i-ker]):min([S1,i+ker]),max([1,j-ker]):min([S2,j+ker]));
        mV=median(dumV(:));
        rm=median(abs(dumV(:)-mV));
        err=abs(V(i,j)-mV)/(rm+ValPar.eps);
        if err>ValPar.UnivTh
            Info(i,j)=0;
            V(i,j)=mV;
        end       
    end
end


            