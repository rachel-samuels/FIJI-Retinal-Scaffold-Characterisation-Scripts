// Set the tolerance level
tolerance = 100;


// CHANGE THIS PRIOR TO USE
// Define the scale factors (pixels per micron)
scale = 0.7227;

// Get the list of ROIs from the ROI Manager
roiManager("list");
roiCount = roiManager("count");

if (roiCount == 0) exit("No ROIs in the ROI Manager");

// Initialize arrays to store all peaks coordinates
allXpeaks = newArray();
allYpeaks = newArray();
allXpeaksScaled = newArray();
allYpeaksScaled = newArray();
widthsX = newArray(); // Array to store the widths between pairs of peaks in x direction
widthsY = newArray(); // Array to store the widths between pairs of peaks in y direction

// Loop through each ROI in the ROI Manager
for (r = 0; r < roiCount; r++) {
    // Select the ROI
    roiManager("select", r);

    // Check if the ROI is a line
    if (selectionType() != 5) continue; // Skip if not a line

    // Get the coordinates of the line ROI
    getSelectionCoordinates(xpoints, ypoints);

    // Get the profile along the line
    profile = getProfile();

    // Find the maxima within the specified tolerance
    peaks = Array.findMaxima(profile, tolerance);

    // Initialise arrays to store the peaks coordinates for the current line
    xpeaks = newArray(peaks.length);
    ypeaks = newArray(peaks.length);
    xpeaksScaled = newArray(peaks.length);
    ypeaksScaled = newArray(peaks.length);

    // Calculate the coordinates of the peaks
    for (i = 0; i < peaks.length; i++) {
        q = peaks[i] / (profile.length - 1);
        xpeaks[i] = xpoints[0] + (xpoints[1] - xpoints[0]) * q; // Original x coordinate
        ypeaks[i] = ypoints[0] + (ypoints[1] - ypoints[0]) * q; // Original y coordinate
        xpeaksScaled[i] = xpeaks[i] / scale; // Scaled x coordinate
        ypeaksScaled[i] = ypeaks[i] / scale; // Scaled y coordinate
    }

    // Append the peaks coordinates to the overall list
    allXpeaks = Array.concat(allXpeaks, xpeaks);
    allYpeaks = Array.concat(allYpeaks, ypeaks);
    allXpeaksScaled = Array.concat(allXpeaksScaled, xpeaksScaled);
    allYpeaksScaled = Array.concat(allYpeaksScaled, ypeaksScaled);

    // Calculate widths between pairs of peaks in x direction: 2 and 3, 4 and 5, etc.
    for (i = 0; i < xpeaksScaled.length; i += 2) {
        if (i + 1 < xpeaksScaled.length) {
            widthX = abs(xpeaksScaled[i + 1] - xpeaksScaled[i]);
            if (widthX != 0) widthsX = Array.concat(widthsX, widthX);
        }
    }

    // Calculate widths between pairs of peaks in y direction: 2 and 3, 4 and 5, etc.
    for (i = 0; i < ypeaksScaled.length; i += 2) {
        if (i + 1 < ypeaksScaled.length) {
            widthY = abs(ypeaksScaled[i + 1] - ypeaksScaled[i]);
            if (widthY != 0) widthsY = Array.concat(widthsY, widthY);
        }
    }
}

// Check if any peaks were found
if (allXpeaks.length > 0) {
    Array.show(allXpeaks, allYpeaks); // Show the coordinates of the peaks in pixels
    makeSelection("points", allXpeaks, allYpeaks); // Draw a point ROI with those coords
    if (widthsX.length > 0) Array.show(widthsX); // Show the non-zero widths between pairs of peaks in microns in x direction
    if (widthsY.length > 0) Array.show(widthsY); // Show the non-zero widths between pairs of peaks in microns in y direction
} else {
    exit("No peaks found");
}
