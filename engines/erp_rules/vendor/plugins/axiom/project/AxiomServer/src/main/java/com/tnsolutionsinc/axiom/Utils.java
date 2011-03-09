package com.tnsolutionsinc.axiom;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Properties;
import org.apache.log4j.Logger;

public class Utils {
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.Utils");

	public static final String DEFAULT_RMI_PORT = "1099";
	public static final String RULE_PATH = "rules";
	public static final String MODEL_PATH = "models";
	public static final String SUPPORT_LIB_PATH = "support_lib";

	public static Properties loadProperties(Properties defaultProperties,
			File file) throws IOException {
		if (defaultProperties == null) {
			defaultProperties = new Properties();
		}
		defaultProperties.load(new FileInputStream(file));
		return defaultProperties;
	}

	public static void writeProperties(File file, Properties p)
			throws IOException {
		FileOutputStream fos = new FileOutputStream(file);
		p.store(fos, "Written by Axiom Server- DEFAULT CONFIGURATION");
	}

	public static Properties getDefaultConfiguration() {
		Properties p = new Properties();
		p.setProperty("rmi.port", DEFAULT_RMI_PORT);
		p.setProperty("rule.path", RULE_PATH);
		p.setProperty("model.path", MODEL_PATH);
		p.setProperty("support.lib.path", SUPPORT_LIB_PATH);
		return p;
	}

	public static URL[] getJarUrls(File[] dirs) {
		ArrayList<File> jarFileList = new ArrayList();
		JarFileFilter jarFileFilter = new JarFileFilter();
		// loop over the list of dirs
		for (int i = 0; i < dirs.length; i++) {
			// make sure the supplied File(s) are actually directory
			if (dirs[i].isDirectory()) {
				// get the directory listing
				File[] fileList = dirs[i].listFiles(jarFileFilter);
				// add the files to the jar file list
				for (int j = 0; j < fileList.length; j++) {
					jarFileList.add(fileList[j]);
					logger.debug("classpath add jar:" + fileList[j]);
				}

			} else {
				logger.warn("Not a jar file:" + dirs[i].getAbsolutePath());
			}
		}
		// now create the urls pointing to the jar files
		URL[] urlList = new URL[jarFileList.size()];
		int count = 0;
		for (File f : jarFileList) {
			try {
				urlList[count] = new URL("jar", "", f.toURL() + "!/");
				logger.debug("created jar url:"
						+ urlList[count].toExternalForm());

				count++;
			} catch (MalformedURLException e) {
				logger.error("Unable to create jar URL for :" + f);
			}
		}
		return urlList;
	}

	public static void listSystemProperties() {
		Properties sysprops = System.getProperties();
		for (Enumeration e = sysprops.propertyNames(); e.hasMoreElements();) {
			String key = (String) e.nextElement();
			String value = sysprops.getProperty(key);
			logger.debug(key + "=" + value);
		}
	}
	
	// handles alt.dir file
	public static File getAltFile(String name){
		String alt_dir=System.getProperty("alt.dir");
		String user_dir=System.getProperty("user.dir");
		File rootDir= new File(user_dir);
		if(alt_dir!=null){
			File subdir = new File(rootDir,alt_dir);
			return new File(subdir,name);
		}else{
			return new File(rootDir,name);
		}
	}
}
