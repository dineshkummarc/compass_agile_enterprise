package com.tnsolutionsinc.axiom.server;

import java.util.HashMap;
import java.util.List;
import java.rmi.Remote;
import java.rmi.RemoteException;

import com.tnsolutionsinc.axiom.context.ExecutionContext;

public interface RuleExecutor extends Remote{
	public HashMap invoke (List ruleset, ExecutionContext executionContext) throws RemoteException;
}
