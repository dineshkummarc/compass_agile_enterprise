package com.tnsolutionsinc.axiom;

import java.net.URL;
import java.net.URLClassLoader;
import org.apache.log4j.Logger;
public class JarClassLoader extends URLClassLoader{
	private URL[] urls;
	public JarClassLoader(URL[] urls,ClassLoader parent) {
	    super( urls ,parent);
	    this.urls = urls;
	}
}
