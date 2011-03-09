package com.tnsolutionsinc.axiom;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Properties;

import org.apache.log4j.Logger; //import org.xeustechnologies.jcl.JarClassLoader;
//import org.xeustechnologies.jcl.JclObjectFactory;
//import org.xeustechnologies.jcl.context.DefaultContextLoader;

import com.tnsolutionsinc.axiom.server.AxiomSecurityManager;
import com.tnsolutionsinc.axiom.server.AxiomServer;
import com.tnsolutionsinc.axiom.server.Server;

public class Main {
	public static final String CONFIGURATION_FILE = "config/configuration.properties";
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.Main");
	private static AxiomServer server = null;
	private JarClassLoader jcl = null;

	// private DefaultContextLoader context = new DefaultContextLoader(jcl);

	public Main() {
		// configure the security manager
		if (System.getSecurityManager() == null) {
			System.setSecurityManager(new AxiomSecurityManager());
		}
		// setup the default properties
		Properties configProperties = Utils.getDefaultConfiguration();
		File configFile = Utils.getAltFile(CONFIGURATION_FILE);
		logger.debug("Config file:"+configFile.getAbsolutePath());
		if (configFile.exists()) {
			logger.debug("Configuration file:" + configFile);
			// load the custom configuration from the file
			try {

				configProperties = Utils.loadProperties(configProperties,
						configFile);
			} catch (IOException ioex) {
				logger.error("Unable to load configuration properties "
						+ configFile);
			}
		} else {
			// write out the defaults
			try {
				Utils.writeProperties(configFile, configProperties);
			} catch (IOException ioex) {
				// logger.error()
			}
		}

		// // create a jar class loader
		// jcl = new JarClassLoader();
		// //jcl.getParentLoader().setEnabled(true);
		//
		//		
		// // add the model path - these jars contain models
		// // used by the rule files. This allows the models
		// // to be physically separated from the support libs
		// System.out.println("Adding model.path:"+configProperties.getProperty("model.path"));
		// //jcl.add(configProperties.getProperty("model.path"));
		// jcl.add("models/");
		// // add the support lib path - these jars contains
		// // addition support libary code used by the rules.
		// // this allows the support libs to be physically
		// // separate from the models
		// System.out.println("Adding support.lib.path:"+configProperties.getProperty("support.lib.path"));
		// //jcl.add(configProperties.getProperty("support.lib.path"));
		// jcl.add("support_lib/");
		// // create a default context
		// context = new DefaultContextLoader(jcl);
		// context.loadContext();
		//		
		//		 
		//
		//		
		// JclObjectFactory factory = JclObjectFactory.getInstance();
		// Object obj = factory.create(jcl,
		// "com.tnsolutionsinc.axiom.server.AxiomServer");
		// logger.debug("Factory created:" + obj);
		// server = (AxiomServer) obj;
		//
		// server.setConfiguration(configProperties);
		// server.startServer();
		// logger.debug("jcl:" + jcl);
		//		
		

		File lib_dir =  Utils.getAltFile("lib");
		File models_dir = Utils.getAltFile("models");
		
		File support_lib_dir = Utils.getAltFile("support_lib");
		File[] jar_lib_dir = new File[3];
		jar_lib_dir[0] = models_dir;
		jar_lib_dir[1] = support_lib_dir;
		jar_lib_dir[2] = lib_dir;
		URL[] jar_urls = Utils.getJarUrls(jar_lib_dir);
		ClassLoader parent_class_loader = this.getClass().getClassLoader();
		jcl = new JarClassLoader(jar_urls,parent_class_loader);
		try {
			Class serverClass = jcl
					.loadClass("com.tnsolutionsinc.axiom.server.AxiomServer");
			server = (AxiomServer)(serverClass.newInstance());
			server.setConfiguration(configProperties);
			server.startServer();
		} catch (Exception ex) {
			System.out.println(ex);
		}
		
		//Utils.listSystemProperties();
		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				server.shutdown(null, "Server terminated with CTRL-C");
			}
		});
	}

	public static void main(String[] args) {
		Main main = new Main();
	}

}
