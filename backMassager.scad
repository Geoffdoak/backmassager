// BACK MASSAGER //

// ----Adjustable Parameters ---- //
height = 15;
peakSpacing = 30;
startX = -40;
endX = 40;
startY = -20;
endY = 20;
increment = 1;
bottomHeight = 3;
cutOff = 1;
$fn=50;


//---- Calculated values ---- //
halfPeakSpacing = peakSpacing / 2;
heightScale = height / 10;
numberRangeX = [for (i=[startX:increment:endX]) i];
numberRangeY = [for (i=[startY:increment:endY]) i];


//---- Maths Functions for 3D Shape---- //
// Two Guassians separated by the peakSpacing, scaled to a height of 10mm
mathsFunction = function(x,y)
    10*(exp(-(pow(((x+halfPeakSpacing)/10),2)+pow(y/10,2)))+exp(-(pow(((x-halfPeakSpacing)/10),2)+pow(y/10,2))));

// Allow only positive values from the function. Return zero if negative
mathsFunctionPositiveOnly = function(x,y)
    (mathsFunction(x,y) + abs(mathsFunction(x,y)))/2;

// Array of points when using the defined range of x values and a given y value
mathsFunctionValues = function(y) [for(i=numberRangeX) [i,mathsFunctionPositiveOnly(i,y)]];


//---- Creating main 3D object ----/ //
// Set of points forming a polygon
polygonFromValuesArray = function(y)
    concat([[startX,0]],mathsFunctionValues(y),[[endX,0],[startX,0]]);

// Extrusion of polygon
module 3DFace(y)
    translate([0,0,y])
        linear_extrude(increment)
            polygon(polygonFromValuesArray(y));

// Main 3D shape created by combining all of the extruded polygons
module 3DShape() {
    scale([1,1,heightScale])
        translate([0,0,-(cutOff+0.1)])
            difference() {
                rotate([90,0,0])
                    union() {
                        for (i=numberRangeY) 3DFace(i);
                    }
                translate([0,-increment/2,0])
                    cube([2*endX,2*endY+2*increment,2*cutOff],center=true);
            }
}


//---- Nubs ----//
// Module that generates rings of nubs
module nubs(number,radius,initialAngle) for (i=[0:360/number:360]) {
    translate([halfPeakSpacing,0,heightScale*mathsFunctionPositiveOnly(halfPeakSpacing-radius,0)-1])
        rotate([0,0,i+initialAngle])
            translate([radius,0,0])
                sphere(1);

    translate([-halfPeakSpacing,0,heightScale*mathsFunctionPositiveOnly(halfPeakSpacing-radius,0)-1])
        rotate([0,0,i+initialAngle])
            translate([radius,0,0])
                sphere(1);
}


//---- Rendering ----//
// Combining all of the shapes
union() {
    // Rendering main 3D shape
    3DShape();

    // Adding an extruded bottom to the shape
    translate([0,0,-(bottomHeight-0.1)])
        linear_extrude(bottomHeight)
            projection(cut=true)
                3DShape();

    // Rendering nubs
    nubs(3,2.5,0);
    nubs(6,5,15);
    nubs(12,7.5,0);
    nubs(24,10,30);
}