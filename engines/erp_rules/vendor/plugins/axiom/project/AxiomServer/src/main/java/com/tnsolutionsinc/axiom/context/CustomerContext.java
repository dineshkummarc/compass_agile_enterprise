package com.tnsolutionsinc.axiom.context;

import org.apache.commons.lang.builder.ToStringBuilder;
 

public class CustomerContext extends Context{

	 

	public String toString(){
		
		
		return new ToStringBuilder(this).
		   appendSuper(super.toString()).
		   toString();

	}
}
