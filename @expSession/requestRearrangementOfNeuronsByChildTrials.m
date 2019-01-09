function requestRearrangementOfNeuronsByChildTrials(obj)
	passData.rearrangementReference = obj.sessionNeuronList;
	notify(obj, 'PleaseRearrangeYourNeurons', dataanalyzer.ParentRequestEventData(passData));
end