package com.tnsolutionsinc.axiom.server;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface Server extends Remote{

	public void restart() throws RemoteException;
	public void reloadRules() throws RemoteException;
	public void shutdown()throws RemoteException;
	
}
