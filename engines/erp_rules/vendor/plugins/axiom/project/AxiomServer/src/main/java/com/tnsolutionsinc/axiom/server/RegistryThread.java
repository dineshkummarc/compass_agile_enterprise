package com.tnsolutionsinc.axiom.server;

import java.rmi.NoSuchObjectException;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;

import org.apache.log4j.Logger;

public class RegistryThread extends Thread {
	private AxiomServer server = null;
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.server.RegistryThread");

	public RegistryThread(AxiomServer server) {
		this.server = server;
	}

	public void run() {
		int port = new Integer(server.getConfiguration().getProperty(
		"rmi.port")).intValue();
		try {
			
			logger.info("Starting RMI registry...");
			server.setRegistry(java.rmi.registry.LocateRegistry.createRegistry(port));
			logger.info("RMI registry ready.");
		} catch (Exception ex) {
			server.shutdown(ex, "Unable to Start RMI Registry- Check if port ("
					+ port + ") is in use.");
		}
	}
	
	public void destroyRegistry() throws NoSuchObjectException  {
		UnicastRemoteObject.unexportObject(server.getRegistry(),true);
	}
}
