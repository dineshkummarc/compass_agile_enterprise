package com.tnsolutionsinc.axiom.server;

import java.io.FileInputStream;
import java.io.IOException;
import java.rmi.AccessException;
import java.rmi.NoSuchObjectException;
import java.rmi.RemoteException;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.Properties;

import org.apache.log4j.Logger;

public class AxiomServer implements Server {
	public static final String VERSION="0.4";
	private Properties config = new Properties();
	private Registry registry = null;
	private RegistryThread registryThread = null;
	private KeepAliveThread keepAlive = null;

	private RuleExecutor ruleExecutor = null;
	private RuleExecutor ruleExecutorStub = null;
	private Server serverStub = null;
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.server.AxiomServer");

	public AxiomServer() {
		logger.info("AxiomServer instance created:"+this);
		logger.info("loaded by:"+this.getClass().getClassLoader());
		
	}

	 

	public Properties getConfiguration() {
		return config;
	}
	public void setConfiguration(Properties config){
		this.config=config;
		logger.info("SERVER CONFIGURATION:");
		logger.info(" rmi.port........:"+config.getProperty("rmi.port"));
		logger.info(" rule.path.......:"+config.getProperty("rule.path"));
		logger.info(" model.path......:"+config.getProperty("model.path"));
		logger.info(" support.lib.path:"+config.getProperty("support.lib.path"));
	}

	public Registry getRegistry() {
		return registry;
	}

	public void setRegistry(Registry registry) {
		this.registry = registry;
	}

	private void startRmiRegistry() throws IOException {
		// try to shutdown any existing rmi registry
		try {
			UnicastRemoteObject.unexportObject(this.registry, true);
			logger.info("Shutdown previous RMI Registry");
		} catch (NoSuchObjectException nsoex) {
			//logger.error("Unable to Shutdown RMI Registry", nsoex);
		}
		
		registryThread = new RegistryThread(this);
		registryThread.start();
	}

	public void startServer() {
		logger.info("Starting Axiom Server. Version "+VERSION);
		 
		try {
			startRmiRegistry();
		} catch (Exception ex) {
			logger.fatal("Could not start RMI Registry");
			logger.fatal(ex);
			logger.info("Terminating Axiom server");
			System.exit(-1);
		}

		logger.info("waiting for RMI registry to be available");

		try {
			Thread.sleep(1000);
			String name = "RuleExecutor";
			ruleExecutor = new RuleExecutorImpl(config);
			ruleExecutorStub = (RuleExecutor) UnicastRemoteObject.exportObject(
					ruleExecutor, 0);

			registry.rebind(name, ruleExecutorStub);

			name = "AxiomServer";
			serverStub = (Server) UnicastRemoteObject.exportObject(this, 0);
			registry.rebind(name, serverStub);

		} catch (Exception e) {
			System.err.println("RuleExecutor exception:");
			e.printStackTrace();
		}

		try {
			String[] registeredObjects = registry.list();
			for (int i = 0; i < registeredObjects.length; i++) {
				logger.info("[" + registeredObjects[i] + "]- bound");
			}
		} catch (AccessException e) {
			// TODO Auto-generated catch block
			logger.error(e);
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			logger.error(e);
		}

		keepAlive = new KeepAliveThread(this, config);
		keepAlive.start();

	}

	public void shutdown(Exception ex, String shutdownMessage) {
		try {
			UnicastRemoteObject.unexportObject(this.registry, true);
		} catch (NoSuchObjectException nsoex) {
			logger.error("Unable to Shutdown RMI Registry", nsoex);
		}
		int exitCode = 0;
		if (ex == null) {
			if (shutdownMessage == null) {
				shutdownMessage = "Normal Shutdown.";
			}
			logger.info(shutdownMessage);
			logger.info("Shutdown complete");
		} else {
			exitCode = -1;
			logger.info("Abnormal Shutdown");
			logger.info(ex);
			logger.info("Shutdown complete");
		}
		System.exit(exitCode);
	}

	@Override
	public void reloadRules() throws RemoteException {
		// TODO Auto-generated method stub
		logger.info("Remote Request for immediate Rule Reload.");
	}

	@Override
	public void restart() throws RemoteException {
		// TODO Auto-generated method stub
		logger.info("Remote Request for immediate Restart.");

	}

	@Override
	public void shutdown() throws RemoteException {
		shutdown(null, "Remote Request for immediate Shutdown.");

	}
	
	public String toString(){
		logger.debug("toString called");
		return ("AXIOM Server");
	}

}
