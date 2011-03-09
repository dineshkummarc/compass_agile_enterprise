package com.tnsolutionsinc.axiom.context;
import java.io.Serializable;
import java.util.HashMap;

import org.apache.commons.lang.builder.ToStringBuilder;
public abstract class Context extends HashMap implements Serializable{

	public String toString(){
		return new ToStringBuilder(this).
		   appendSuper(super.toString()).
		   toString();

	}
}
