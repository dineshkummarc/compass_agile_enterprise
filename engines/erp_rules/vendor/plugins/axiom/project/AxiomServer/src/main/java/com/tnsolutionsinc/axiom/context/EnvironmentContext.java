package com.tnsolutionsinc.axiom.context;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.builder.ToStringBuilder;

public class EnvironmentContext extends Context{

	
	
	public String toString(){
		return new ToStringBuilder(this).
		   appendSuper(super.toString()).
		   toString();

	}
}
