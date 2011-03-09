package com.tnsolutionsinc.axiom.client;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.log4j.Logger;

import com.tnsolutionsinc.axiom.context.ExecutionContext;
import com.tnsolutionsinc.axiom.server.Server;
import com.tnsolutionsinc.axiom.server.RuleExecutor;

public class AxiomClient {
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.client.AxiomClient");
	private String host;
	private int port = 1099;
	private Registry registry = null;

	public AxiomClient(String host, int port) {
		this.host = host;
		this.port = port;
	}

	public Registry getRegistry()throws Exception{
		if (registry == null) {
			logger.info("Locating RMI registry");
			registry = LocateRegistry.getRegistry(host, port);
			logger.info("RMI Registry=>"+registry);
		}
		return registry;
	}

	public HashMap invoke(List ruleset, ExecutionContext executionContext)
			throws Exception {
		String name = "RuleExecutor";
		// String serverName="AxiomServer";
		registry = getRegistry();
		String[] boundObjects = registry.list();
		for (int i = 0; i < boundObjects.length; i++) {
			logger.info("Found [" + boundObjects[i] + "]");
		}
		RuleExecutor executor = (RuleExecutor) registry.lookup(name);
		// Server server = (Server)registry.lookup(serverName);
		long startTime = new java.util.Date().getTime();
		HashMap result = executor.invoke(ruleset, executionContext);
		long endTime = new java.util.Date().getTime();
		logger.info(result);
		logger.info("executed in (" + (endTime - startTime) + ") msecs.");
		return result;
	}

	public void shutdownServer() throws Exception {

		String serverName = "AxiomServer";
		registry = getRegistry();
		String[] boundObjects=registry.list();
		for(int i=0;i<boundObjects.length;i++){
			logger.debug(boundObjects[i]+"-bound");
		}
		Server server = (Server) registry.lookup(serverName);

		server.shutdown();

	}

	public static void main(String[] args) {
		logger.debug("executing AxiomClient main");
		// if (System.getSecurityManager() == null) {
		// System.setSecurityManager(new SecurityManager());
		// }
		try {
			logger.info("test AxiomClient");
			List ruleset = new ArrayList();
			ruleset.add("Hello");
			ExecutionContext executionContext = new ExecutionContext();
			com.tnsolutionsinc.compass.model.Message message = new com.tnsolutionsinc.compass.model.Message();
			message.setStatus(com.tnsolutionsinc.compass.model.Message.HELLO);
			executionContext.put("message", message);
			executionContext.put("monkey", new HashMap());

			AxiomClient client = new AxiomClient("127.0.0.1", 1099);
			HashMap results = client.invoke(ruleset, executionContext);

			logger.info("results:" + results);

			client.shutdownServer();
		} catch (Exception e) {
			logger.error("Exception:");
			logger.error(e);
			e.printStackTrace();
		}
	}

}
