pkg load image
addpath('~/octave/iso2mesh/')
addpath('~/octave/zmat/')
addpath('~/octave/brain2mesh/')

load 'mesh/nodes.mat'
load 'mesh/elements.mat'
load 'mesh/faces.mat'

% light
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([0 0 1]);
print(fig, 'mesh/brain_light.png', '-dpng','-r300');

fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [0,0,0],  'edgecolor', [0.5,0.5,0.5]);
axis off;
view([0 0 1]);
print(fig, 'mesh/brain_dark.png', '-dpng','-r300');

% top - bottom
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([0 0 1]);
print(fig, 'mesh/brain_top2bottom.png', '-dpng','-r300');

% bottom - top
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([0 0 -1]);
print(fig, 'mesh/brain_bottom2top.png', '-dpng','-r300');

%  rear - front 
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([1 0 0]);
print(fig, 'mesh/brain_rear2front.png', '-dpng','-r300');

% side
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([-1 0 0]);
print(fig, 'mesh/brain_side.png', '-dpng','-r300');

% front 
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([0 1 0]);
print(fig, 'mesh/brain_front.png', '-dpng','-r300');

% 3-4 light
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [1,1,1],  'edgecolor', [0.7,0.7,0.7]);
axis off;
view([0.75 0.5 0]);
print(fig, 'mesh/brain_34_light.png', '-dpng','-r300');

% 3-4 dark
fig = figure('Visible', 'off');
plotmesh(nodes, faces, 'facecolor', [0,0,0],  'edgecolor', [0.5,0.5,0.5]);
axis off;
view([0.75 0.5 0]);
print(fig, 'mesh/brain_34_dark.png', '-dpng','-r300');



