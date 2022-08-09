function [x,y,u,v,dist]=RemoveDistantParticles(x,y,XX,YY,u,v,dist,dx)
% INPUT:
% - x,y --> particle position
% - XX,YY --> center of the subdomain
% - u,v --> particle velocity
% - dist --> distance in feature space, dimensionless
% - dx --> grid distance

% OUTPUT:
% - x,y --> position of close particles
% - u,v --> velocity of close particles
% - dist --> distance of close particles

P = (x-XX).^2 + (y-YY).^2;
appo = find(P< (15*dx)^2);
x=x(appo);
y=y(appo);
u=u(appo);
v=v(appo);
dist=dist(appo);
