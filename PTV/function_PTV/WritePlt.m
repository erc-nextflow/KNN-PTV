function WritePlt(NomeFileOut,Varia,Titolo,NomeVar,TitoloZona)%%modificata a partire da routine Mauro
    
[H,W,NVar]=size(Varia);
%{
Utilizzare qualcosa del genere per le stringhe
   TitoloZona=sprintf('%s\n',NomeOut);TitoloZona(find(TitoloZona==10))=0;
   Titolo=sprintf('b16\n');Titolo(find(Titolo==10))=0;
   NomeVar=sprintf('x\ny\nu\nv\nSN\nInfo\n');NomeVar(find(NomeVar==10))=0;;
   
%}
%output
%    
    %TEST
    TecIntest='#!TDV71 ';

    %apertura file binario di output .plt
    fris=fopen(NomeFileOut,'wb');

    %scrittura nel file di output del TEST 
    fwrite(fris, TecIntest, 'char');

    %scrittura nel file di output di 1 (ordine dei bytes BO???)
    Lungo=1;
    fwrite(fris, Lungo, 'int32');

    %scrittura del titolo
    
    fwrite(fris, Titolo, 'int32');  

    %scrittura del numero delle variabili
    Lungo=NVar;
    fwrite(fris, Lungo, 'int32');
    fwrite(fris, NomeVar, 'int32');


    Lungo=299.0;
    fwrite(fris, Lungo, 'float32');

    %ZONE NAME

    fwrite(fris, TitoloZona, 'int32'); 

    %scrittura del BLOCK POINT
    Lungo=1;
    fwrite(fris, Lungo, 'int32');

    %scrittura del COLORE
    Lungo=-1;
    fwrite(fris, Lungo, 'int32');

    %scrittura nel file di output della larghezza img W
    Lungo=W;
    fwrite(fris, Lungo, 'int32');

    %scrittura nel file di output della altezza img H
    Lungo=H;
    fwrite(fris, Lungo, 'int32');

    %scrittura nel file di output della dimensione Z
    Lungo=1;
    fwrite(fris, Lungo, 'int32');

    %scrittura nel file di output di 357.0 (bo????)
    Float=357.0;
    fwrite(fris, Float, 'float32');

    %scrittura nel file di output di 299.0 (bo????)
    Float=299.0;
    fwrite(fris, Float, 'float32');

    %scrittura nel file di output di 0 (bo????)
    Lungo=0;
    fwrite(fris, Lungo, 'int32');

    %sizeof variabili
    Lungo=1;
    for i=1:NVar
        fwrite(fris, Lungo, 'int32');
    end

    %scrittura nel file di output delle matrici x,y,u,v,up,vp (variabili)
    Varia=permute(Varia,[3 2 1]);
    %permute(reshape(Mat,NVar,W,H),[3 2 1]);
%    fwrite(fris, Mat, 'double');
    % {
    
    fwrite(fris,Varia,'float32');
%     for i=1:H
%         for j=1:W
%             for k=1:NVar
%                 fwrite(fris, Varia(i,j,k), 'float32');
%             end
%         end
%     end
    
    %}
    fclose(fris);
    return