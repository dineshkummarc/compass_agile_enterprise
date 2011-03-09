package com.tnsolutionsinc.axiom.server;

import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.util.Properties;

import org.apache.log4j.Logger;

public class KeepAliveThread extends Thread {
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.server.KeepAliveThread");

	private Server server=null;
	Properties config=null;
	public KeepAliveThread(Server server,Properties p){
		this.server=server;
		config=p;
		
	}
	private void touchRegistry(){
		String host =config.getProperty("rmi.host");
		int port = new Integer(config.getProperty("rmi.port")).intValue();
		try {
			Registry registry = LocateRegistry.getRegistry(host,port);
			String[] boundObjects=registry.list();
			for(int i=0;i<boundObjects.length;i++){
				logger.debug(boundObjects[i]+"-bound");
			}
		} catch (RemoteException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	public void run() {
		logger.debug("KeepAlive started");
		while (true) {
			try {
				touchRegistry();
				Thread.sleep(120000);
				
			} catch (InterruptedException ex) {

			}
		}
	}
}
