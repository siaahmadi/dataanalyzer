function c = constant(constantName)

CONST = dataanalyzer.internal.p___loadConstantsDB();
c = CONST.(constantName);