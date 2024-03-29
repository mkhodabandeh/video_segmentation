function Plotisofigregpr()
%clear all;close all;clc;

title('Boundary Benchmark on BSDS');
hold on;

%The human performance must be estimated
% plot(0.700762,0.897659,'go','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',10);
% isoF lines
[p,r] = meshgrid(0.01:0.001:1,0.01:0.001:1);
F=2*p.*r./(p+r);
[C,h] = contour(p,r,F);
hasbehavior(h,'legend',false);
hold off

% colormap green
map=zeros(256,3); map(:,1)=0.8; map(:,2)=0.8; map(:,3)=0.8; colormap(map);

box on;
grid on;
set(gca,'XTick',0:0.1:1);
set(gca,'YTick',0:0.1:1);
set(gca,'XGrid','on');
set(gca,'YGrid','on');
xlabel('Recall');
ylabel('Precision');
title('');
% axis square;
axis([0 1 0 1]);


%legend('Human','Location','NorthEast')
