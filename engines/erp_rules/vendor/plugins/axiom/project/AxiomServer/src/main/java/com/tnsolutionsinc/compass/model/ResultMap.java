package com.tnsolutionsinc.compass.model;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.lang.builder.ToStringBuilder;
public class ResultMap extends HashMap{
	private List<String> ruleExecutionList = new ArrayList<String>();
	public List getRuleExecutionList(){
		return ruleExecutionList;
	}
	
	public void addRuleFired(String rulename){
		ruleExecutionList.add(rulename);
	}
	public String toString(){
		return new ToStringBuilder(this).
		   appendSuper(super.toString()).
		   append("ruleExecutionList",ruleExecutionList).
		   toString();

	}
}
