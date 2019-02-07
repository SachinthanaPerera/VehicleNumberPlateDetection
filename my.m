clc;
clear all;%delete the variables
close all;
imtool close all;
workspace;

%read the image
I=imread('image9.jpg');
subplot(4,3,1);
imshow(I);
title('Original Image');

%convert to gray scale
bw=rgb2gray(I);
subplot(4,3,2);
imshow(bw);
title('Gray scale Image');

%detect edges
sobe=edge(bw,'sobel',0.2);
subplot(4,3,3);
imshow(sobe);
title('detect edges');

%do the dialation
se=strel('square',3);
dil=imdilate(sobe,se);
subplot(4,3,4);
imshow(dil);
title('dialation');

%fill the holes
fill=imfill(dil, 'holes');
subplot(4,3,5);
imshow(fill);
title('fill the holes');

%do the erosion
dia=strel('square',1);
diamon=imerode(fill,dia);
subplot(4,3,6);
imshow(diamon);
title('Do erosion');


li=strel('line',5,30);
linee=imerode(diamon,li);
subplot(4,3,7);
imshow(linee);
title('line erode');

% removes all connected components (objects) that have fewer than P pixels
f=bwareaopen(linee,300);%pi
subplot(4,3,8);
imshow(f);
title('remove small images');

%get outermost boundaries of the objects
filledImage=imfill(f,'holes');

%boundaries=bwboundaries(filledImage);
subplot(4,3,9);
imshow(filledImage);
title('get outermost boundaries of the objects');

[labeledImage, numberOfObjects]=bwlabel(filledImage);
subplot(4,3,10);
imshow(labeledImage);
title('Labeled objects');
measurements=regionprops(labeledImage,'Perimeter','FilledArea');

%store measurements into individual arrays
perimeters=[measurements.Perimeter];
filledAreas=[measurements.FilledArea];

%calculate circularities
circularities=perimeters.^2./(4*pi*filledAreas);

%print
fprintf('#,Perimeter,FilledArea,Circularity\n');
for Number = 1 : numberOfObjects
    fprintf('%d,%9.3f,%11.3f,%11.3f\n',Number,perimeters(Number),filledAreas(Number),circularities(Number));
end
for Number = 1 : numberOfObjects
if (circularities(Number)>1.5 && circularities(Number)<4.0)

img1=(labeledImage==Number); 
figure,imshow(img1);
[row,col] = find(img1);
length=max(row)-min(row)+2;
breadth=max(col)-min(col)+2;
target=uint8(zeros([length breadth]));
figure,imshow(target);
sy=min(col)-1;
sx=min(row)-1;

for i=1:size(row,1)
    x=row(i,1)-sx;
    y=col(i,1)-sy;
    target(x,y)=I(row(i,1),col(i,1));
end
figure
imshow(target);title('Number Plate');
    
end
end

