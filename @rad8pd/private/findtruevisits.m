function [trueVisits, determinedVisits, changeOfMindVisits] = findtruevisits(sv, r, tolRad, veryFarThreshold, trailingNumFramesThreshold)

[fp, fpi] = phaprec.parsemz.rad8.farthestPointOfEachSectorVisit(sv, r);

veryFarVisits = fp > veryFarThreshold;

farEnoughVisits = fp > tolRad;
validForMovementTest = fpi - sv(1:end-1) > trailingNumFramesThreshold;
outwardMovement = false(size(fp));
outwardMovement(farEnoughVisits & validForMovementTest) = ...
	phaprec.parsemz.rad8.p___isIncreasingUpTo(r, fpi(farEnoughVisits & validForMovementTest), trailingNumFramesThreshold);

changeOfMindVisits = (farEnoughVisits & ~veryFarVisits) & validForMovementTest & outwardMovement;
determinedVisits = veryFarVisits;
trueVisits = determinedVisits | changeOfMindVisits;