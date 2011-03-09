package com.tnsolutionsinc.axiom.server;

import java.security.Permission;
import java.rmi.RMISecurityManager;

import org.apache.log4j.Logger;
public class AxiomSecurityManager extends RMISecurityManager {
	//public static Logger logger = Logger
	//.getLogger("com.tnsolutionsinc.axiom.server.AxiomSecurityManager");
	public void checkCreateClassLoader() {
		//logger.debug("checkCreateClassLoader" );
	}

	public void checkPermission(Permission perm) {
		//logger.debug("checkPermission:"+perm );
	}

	public void checkPermission(Permission perm, Object context) {
		//logger.debug("checkPermission:"+perm +", ctx:"+context);
	}

	public void checkPropertiesAccess() {
		//logger.debug("checkPropertiesAccess" );
	}

	public void checkPropertyAccess(String key) {
		//logger.debug("checkPropertyAccess" +key);

	}
}
