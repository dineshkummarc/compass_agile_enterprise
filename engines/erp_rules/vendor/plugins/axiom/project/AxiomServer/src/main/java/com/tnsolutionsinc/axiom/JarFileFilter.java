package com.tnsolutionsinc.axiom;

import java.io.File;
import java.io.FileFilter;

public class JarFileFilter implements FileFilter {

	@Override
	public boolean accept(File f) {
		if(f.getName().toLowerCase().endsWith(".jar")){
			return true;
		}
		return false;
	}

}
